--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll
import           Hakyll.Web.Sass

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

    match "css/*.css" $ do
        route   idRoute
        compile compressCssCompiler

    -- import scss --
    match ("css/**/*.scss" .||. "css/*.scss") $
        compile idCompiler

    create ["css/default.css"] $ do
        route   idRoute
        compile $ do
            (dummy:_) <- loadAll "css/**/*.scss"
            (mainCSS:_) <- loadAll "css/default.scss"
            renderSass dummy    -- watch dependencies
            css <- renderSass mainCSS
            return $ compressCss <$> css

    match (fromList ["about.markdown", "contact.markdown"]) $ do
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

    match "pages/*" $ do
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

    --- parse cover folder and generate script to randomize background picture ---
    match "templates/background-switcher.html" $
        compile $ do
            covers <- loadAll (fromGlob "images/cover/**" .&&. complement "images/**/*.psd")
            let coverNames = map itemIdAsBody covers
            let backgroundCtx =
                    listField "imageNames" defaultContext (return coverNames)

            --- perform template operations on this template, then parse back as template ---
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

idCompiler :: Compiler (Item String)
idCompiler = getResourceString >>= (\(Item i x) -> makeItem x)
