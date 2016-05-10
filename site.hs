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

    match ("images/**/*.jpg" .||. "images/*.jpg") $ do
        route idRoute
        compile $ getResourceLBS >>= withItemBody (unixFilterLBS "mozjpeg" [])

    match (fromGlob "images/**" .&&. complement "images/**/*.psd") $ do
        route   idRoute
        compile copyFileCompiler

    match (fromGlob "images/cover/**" .&&. complement "images/**/*.psd") $ version "filename" $
        compile $ getResourceFilePath >>= makeItem

    match "css/*.css" $ do
        route   idRoute
        compile compressCssCompiler

    -- import scss --
    match ("css/**/*.scss" .||. "css/*.scss") $ compile idCompiler

    create ["css/default.css"] $ do
        route   idRoute
        compile $ do
            (dummy:_) <- loadAll "css/**/*.scss"
            (mainCSS:_) <- loadAll "css/default.scss"
            renderSass dummy    -- watch dependencies
            renderSass mainCSS >>= withItemBody (return . compressCss)

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
                    constField "digest" "Bla"                `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    --- parse cover folder and generate script to randomize background picture ---
    match "templates/background-switcher.html" $
        compile $ do
            covers <- loadAll (fromGlob "images/cover/**" .&&. complement "images/**/*.psd" .&&. hasVersion "filename")
            let backgroundCtx =
                    listField "imageNames" defaultContext (return covers)

            --- perform template operations on this template, then parse back as template ---
            getResourceBody
                >>= applyAsTemplate backgroundCtx
                >>= withItemBody (return . readTemplate)

    match "templates/*" $ compile templateCompiler


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext

idCompiler :: Compiler (Item String)
idCompiler = getResourceString >>= (\(Item i x) -> makeItem x)
