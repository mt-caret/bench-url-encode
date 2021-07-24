{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Criterion.Main
import qualified Data.ByteString.Char8 as B
import qualified Data.Char as C
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import qualified Data.Text.IO as TIO
import Hedgehog ((===))
import qualified Hedgehog as H
import qualified Hedgehog.Gen as H.Gen
import qualified Hedgehog.Range as H.Range
import qualified Network.HTTP as HTTP
import qualified Network.HTTP.Types as HTTPTypes
import qualified Numeric as N

-- import Options.Generic

--data Opt
--  = Benchmark {path :: FilePath}
--  | Fuzz
--  deriving (Generic, Show)
--
-- instance ParseRecord Opt

oldUrlEncode :: T.Text -> T.Text
oldUrlEncode = T.pack . HTTP.urlEncode . T.unpack

{- Code copied from Pandoc starts here -}

-- | Convert UTF8-encoded ByteString to Text, also
-- removing '\r' characters.
toText :: B.ByteString -> T.Text
toText = T.decodeUtf8 . filterCRs . dropBOM
  where
    dropBOM bs =
      if "\xEF\xBB\xBF" `B.isPrefixOf` bs
        then B.drop 3 bs
        else bs
    filterCRs = B.filter (/= '\r')

fromText :: T.Text -> B.ByteString
fromText = T.encodeUtf8

{- Code copied from Pandoc ends here -}

newUrlEncode :: T.Text -> T.Text
newUrlEncode = toText . HTTPTypes.urlEncode True . fromText

customUrlEncode ::
  T.Text ->
  T.Text
customUrlEncode =
  go []
  where
    go accum text =
      let (l, r) = T.break requiresEncoding text
       in case T.uncons r of
            Nothing -> T.concat (reverse (l : accum))
            Just (hd, tl) -> go (percentEncode hd : l : accum) tl

    percentEncode = T.pack . ('%' :) . flip N.showHex "" . fromEnum

    requiresEncoding ch
      | 'a' <= ch && ch <= 'z' = False
      | 'A' <= ch && ch <= 'Z' = False
      | '0' <= ch && ch <= '9' = False
      | ch == '-' = False
      | ch == '_' = False
      | ch == '.' = False
      | ch == '~' = False
      | otherwise = True

propOldAndNewMatch :: H.Property
propOldAndNewMatch =
  H.property $ do
    str <- H.forAll $ H.Gen.text (H.Range.linear 0 100) H.Gen.unicodeAll
    oldUrlEncode str === newUrlEncode str

tests :: IO Bool
tests =
  H.checkParallel $
    H.Group
      "check old an new encodings match"
      [ ("propOldAndNewMatch", propOldAndNewMatch)
      ]

main :: IO ()
main = do
  _ <- tests
  aliceInWonderland <- TIO.readFile "./test-files/alice-in-wonderland.txt"
  wagahaiwaNekodearu <- TIO.readFile "./test-files/wagahaiwa_nekodearu.txt"
  defaultMain
    [ bgroup
        "alice-in-wonderland"
        [ bench "oldUrlEncode (HTTP)" $ nf oldUrlEncode aliceInWonderland,
          bench "newUrlEncode (http-types)" $ nf newUrlEncode aliceInWonderland,
          bench "customUrlEncode" $ nf customUrlEncode aliceInWonderland
        ],
      bgroup
        "wagahaiwa-nekodearu"
        [ bench "oldUrlEncode (HTTP)" $ nf oldUrlEncode wagahaiwaNekodearu,
          bench "newUrlEncode (http-types)" $ nf newUrlEncode wagahaiwaNekodearu,
          bench "customUrlEncode" $ nf customUrlEncode wagahaiwaNekodearu
        ]
    ]

--opts <- getRecord "bench-url-encode"
--case opts of
--  Benchmark path -> do
--    fileContents <- TIO.readFile path
--    defaultMain
--      [ bgroup
--          "urlEncode"
--          [ bench "oldUrlEncode (HTTP)" $ nf oldUrlEncode fileContents,
--            bench "newUrlEncode (http-types)" $ nf newUrlEncode fileContents
--          ]
--      ]
--  Fuzz -> error "unimplemented"
