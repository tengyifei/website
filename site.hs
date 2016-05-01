--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll


--------------------------------------------------------------------------------
main :: IO ()
main = hakyll $ do
    --- old stuff ---

    match "game_of_war/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "irobotics/*" $ do
        route   idRoute
        compile copyFileCompiler

    --- domain settings ---

    match "CNAME" $ do
        route   idRoute
        compile copyFileCompiler

    --- blog ---

    match (fromGlob "images/**" .&&. complement "images/**/*.psd") $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match (fromList ["about.rst", "contact.markdown"]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Archives"            `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let indexCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Home"                `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/background-switcher.html" $
        compile $ do
            covers <- loadAll (fromGlob "images/cover/**" .&&. complement "images/**/*.psd")
            let coverNames = map itemIdAsBody covers
            let backgroundCtx =
                    listField "imageNames" defaultContext (return coverNames)

            getResourceBody
                >>= applyAsTemplate backgroundCtx
                >>= (\(Item i x) -> makeItem $ readTemplate x)

    match "templates/*" $ compile templateCompiler


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext

itemIdAsBody :: Item CopyFile -> Item String
itemIdAsBody (Item i _) = Item i (toFilePath i)
