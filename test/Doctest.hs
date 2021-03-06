module Doctest where

import Control.Applicative
import Control.Monad
import Data.List
import System.Directory
import System.FilePath
import Test.DocTest
import Test.DocTest.Prop

main :: IO ()
main = getSources >>= \sources -> doctest $
    "-isrc"
  : "-idist/build/autogen"
  : "-optP-include"
  : "-optPdist/build/autogen/cabal_macros.h"
  : sources

getSources :: IO [FilePath]
getSources =
    filter (\n -> ".hs" `isSuffixOf` n && n /= "./Setup.hs") <$> go "."
  where
    go dir = do
      (dirs, files) <- getFilesAndDirectories dir
      (files ++) . concat <$> mapM go (filter (not . (== "./test")) dirs)

getFilesAndDirectories :: FilePath -> IO ([FilePath], [FilePath])
getFilesAndDirectories dir = do
  c <- map (dir </>) . filter (`notElem` ["..", "."])
           <$> getDirectoryContents dir
  (,) <$> filterM doesDirectoryExist c <*> filterM doesFileExist c
