---
title: Redis blogging system design
published: 2014-12-31T16:27:17Z
categories: Computer Science,Web
tags: Redis
---

<p>To be honest, I never regarded Redis as a database system capable of standing on its own, using it as a rudimentary key-value store or LRU cache most of the time. But due to a number of technical limitations, I was stuck with Redis as the only DB option for a project. As I trudged through the implementation however, I realized that Redis boasts powerful and flexible data structures. Despite it being necessary for any query with moderate complexity to be explicitly handled by code, the paradigms are well-structured and when employed correctly, will pay off with sheer speed of the database. In this article I'll discuss an approach for implementing blog functionality, taking experience from similar components in my project.<!--more--></p>
<h2>Redis data structure</h2>
<p>Four kinds of data structures complement the key-value scheme in Redis, namely Sets, Hash Sets, Sorted Sets, and Lists. The table below shows their features:</p>
<p>[table] Type,Description,Underlying Implementation</p>
<p>Set,"Analog to its mathematical counterpart, unordered collection",Hash maps</p>
<p>Hash Set,"Key-value store within a key, can fetch and update all fields with ease",Hash maps</p>
<p>Sorted Set,"Collection that sorts elements by score and in lexicographical order",Skip lists</p>
<p>List,"Plain doubly linked list supporting blocking inserts/removes",Linked list (Duh) [/table]</p>
<p>These generic structures provide the building blocks for storing and organizing virtually any kind of information. At first glance, we could use sorted sets to hold article objects and index them by date, but this is rather rigid. What if someone wants to filter articles by categories, authors or tags? Furthermore, any queries regarding topics other than dates would require grabbing and sifting through the entire list of articles (plus their content!), which raises performance alert for moderately large blogs. What can we do about it?</p>
<h2>Separating content from header</h2>
<p>The might well be the natural response from any programmer. It is generally observed that article metadata, including titles, authorship and dates, are frequently requested en masse, whereas at any time we are only concerned with a few if not a single piece of article content. Moving article content into a separate key can decrease the overhead in traversing article sorted set and enables extensions to the design. Entries in the sorted set can have a string reference to its content key. Outlined below is our primitive schema, in some arbitrary format:</p>
<pre class="toolbar:2 lang:ruby decode:true"># A sorted set containing all article information headers
article:headers : epoch time =&gt; json encoded header
    title   - Title of article
    date    - Date published
    content - Key to a Redis string holding article content

# Content for article identified by {key}
article:content:{key} : plain HTML of article content</pre>
<p>Using JSON to serialize article headers is somewhat discouraged for Redis has native support for object properties via HashMap. But I'll leave it as it is for simplicity's sake at this stage.</p>
<p>The content field in article header acts much like a pointer: to obtain the content we need the key for an article header, which upon decode produces another key leading us to the content.</p>
<p>There are still restrictions, though. So far we assumed that articles are only sorted by dates, which could prove insufficient for more advanced sites. The easy way out, that is, creating multiple sorted sets with different type of indices, would require duplicating the article header multiple times. As the headers grow in complexity this method becomes increasingly inefficient, which brings us to:</p>
<h2>Another layer of indirection</h2>
<p>When refactoring we tend to extract and combine similar funcionalities. This method of code reuse have found applications in database schema design as well. If we separate article header from the sorted sets and refer to it by a header ID, the cost of maintaining multiple sorted sets diminishes greatly.</p>
<pre class="toolbar:2 lang:ruby decode:true"># Sorted sets indexing header IDs
article:index:date : epoch time =&gt; header_key
article:index:comment_count : comment count =&gt; header_key
article:index:no_of_likes : number of likes =&gt; header_key

# Hash sets each containing a single article header
article:header:{header_key} : header identified by {header_key}
    title   - Title of article
    date    - Date published
    url     - Link to the article
    content - Key to a Redis string holding article content

# Content for article identified by {key}
article:content:{key} : plain HTML of article content</pre>
<p>Each article header now naturally corresponds to a Redis HashSet object instead of a monolithic JSON string. Sorted sets function solely as indices and article content strings exclusively store content. This elegant separation of responsibilities permits one component to be changed without affecting the others, so long as the various "pointers" remain unchanged. I've made three example indices based on potential use cases e.g. time of publishing, comment count, number of "likes", under which all articles are sorted.</p>
<h2>Browsing articles by tags</h2>
<p>Redis sorted sets are very powerful data structures. By intersecting different sorted sets we can achieve filtering by tags with ease. Let each tag be a sorted set comprising all the article header IDs that fall within the particular tag, but all having a score of zero (in reality this score is of no practical value, as we'll see later on). We can compute the list of articles under tag X by intersecting it with a sorted set index of our choosing. Specifically, suppose there are the following sorted sets:</p>
<pre class="toolbar:2 lang:ruby decode:true"># Sorted set containing article header IDs tagged with 'movie'
# ID follows score
article:tags:movie
    0 =&gt; 1,
    0 =&gt; 3

# Sorted set indexing article header IDs by comment count
article:index:comment_count
    3 =&gt; 1,
    2 =&gt; 2,
    5 =&gt; 3,
    3 =&gt; 4</pre>
<p>To cherry pick items in <span class="lang:default highlight:0 decode:true  crayon-inline">article:index:comment_count</span>, we use the ZINTERSTORE command:</p>
<pre class="wrap:true lang:default decode:true">ZINTERSTORE article:computed_tags:movie:comment_count 2 article:tags:movie article:index:comment_count WEIGHTS 0 1</pre>
<p>The result of the intersection is stored in <span class="lang:default highlight:0 decode:true  crayon-inline">article:computed_tags:movie:comment_count</span> . By running the command with weights [0, 1], the scores in the tags sorted set are ignored while those in <span class="lang:default highlight:0 decode:true  crayon-inline ">article:index:comment_count</span> are transferred as-is. This ultimately preserves the score in the index:</p>
<pre class="toolbar:2 lang:default decode:true">article:computed_tags:movie:comment_count
    3 =&gt; 1,
    5 =&gt; 3</pre>
<p>This command runs roughly in O(N log N) time, where N is the size of the tag sorted set. This is no better than grabbing the two lists and doing filtering on our own. However, considering that Redis is a highly optimized database running native code, the reduction in network transfer size and the elegance of the approach should far outweigh any gains from a custom filtering algorithm implemented in a dynamic web scripting language.</p>
<p>We can even process any combination of tags given as Boolean expressions involving AND and OR, since AND is equivalent to intersection and OR is equivalent to union. Finding out posts under <span class="lang:default decode:true  crayon-inline ">(movie AND music) OR food</span> sorted by date is accomplished by taking <span class="lang:default decode:true  crayon-inline">union(intersect("movie", "music"), "food")</span>, then intersecting it with the date index.</p>
<h2>More fun with ZINTERSTORE</h2>
<p>Much freedom comes from the weight option. We can rank articles using a combination of factors e.g. 25% comment count, 25% views and 50% number of likes by doing an intersection of index sorted sets (all of them have the same elements) with the respective weights set.</p>

