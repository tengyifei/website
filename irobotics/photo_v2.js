!function(t){function e(){t("#album-list").prepend("<p>Robot temporarily malfunctioning. Check back later. :P</p>")}var a=function(){this.nextAcademicYear=function(t){return t>=8},this.toYear=function(t){var e=new Date(1e3*t),a=e.getFullYear()
return this.nextAcademicYear(e.getMonth()+1)&&a++,a},this.get=function(t){var e,a={"iRobotics Demno at 4H":2013},r=Number.MAX_VALUE,i=Number.MIN_VALUE,n=function(){this.handler=function(t){var n=this.toYear(t.datetime)
if(null!=a[t.title])n=a[t.title]
else if(null==t.title&&(t.title=""),null!=(e=t.title.match(/20\d\d-20\d\d/)))n=parseInt(e[0].substr(0,4))+1
else if(null!=(e=t.title.match(/20\d\d-\d\d/)))n=parseInt(e[0].substr(0,4))+1
else if(null!=(e=t.title.match(/20\d\d/)))n=parseInt(e[0].substr(0,4)),2014==n&&new Date(1e3*t.datetime).getMonth()>=7?n=this.toYear(t.datetime):(t.title.toLowerCase().indexOf("fall")>-1||t.title.toLowerCase().indexOf("quad")>-1)&&n++
else if(null!=(e=t.title.match(/\d\d?\/\d\d?\/\d\d/))){n=parseInt(e[0].substr(e[0].length-2,2))+2e3
var l=parseInt(e[0].split("/")[0])
this.nextAcademicYear(l)&&n++}t.year=n,n>i&&(i=n),r>n&&(r=n)}}
n.prototype=this
var l=new n
return t.forEach(l.handler,l),[r,i]}},r=function(e,a){var r=e[0],i=e[1],n=[]
this.fillAlbumArray=function(){for(var t=0;i-r+1>t;t++)n[n.length]={year:t+r,albums:[]}
a.forEach(function(t){n[t.year-r].albums.push(t)})},this.showAlbum=function(){for(var e=t("#album-list"),a=n.length-1;a>=0;a--){var r=n[a],i=r.albums,l="alb-"+r.year
e.append('<h3 class="photo-header" data-album="'+l+'">'+(r.year-1)+"-"+r.year+" ↓</h3>"),e.append('<div id="'+l+'" class="photogroup photogroup-hidden"></div>')
for(var s=t("#"+l),o=0;o<i.length;o++)s.append('<div class="album-each"><a target="_blank" href="'+i[o].link+'"><br><img class="album" src="http://imgur.com/'+i[o].cover+'b.jpg" alt="'+i[o].title+'"><br>'+i[o].title+"<br></a>")}t("#album-list h3").click(function(e){var a=t("#"+t(e.target).data("album")),r="photogroup-hidden"
a.hasClass(r)?a.removeClass(r):a.addClass(r)})},this.render=function(){this.fillAlbumArray(),this.showAlbum()}}
t.ajax({url:"https://api.imgur.com/3/account/irobotics/albums/",method:"GET",headers:{Authorization:"Client-ID 0ad87485d642182",Accept:"application/json"},data:{},success:function(t){if(t.success&&200===t.status)try{var i=t.data.sort(function(t,e){return t.datetime>e.datetime?-1:t.datetime==e.datetime?0:1}),n=(new a).get(i)
new r(n,i).render()}catch(l){e()}else e()},error:function(){e()}})}(jQuery)
