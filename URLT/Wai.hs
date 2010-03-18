module URLT.Wai where

import Control.Applicative.Error
import qualified Data.ByteString.Char8 as S
import qualified Data.ByteString.Lazy.Char8 as L
import Network.Wai
import Network.Wai.Enumerator
import URLT.TH

handleWai :: (url -> String) -> (String -> Failing url) -> ((url -> String) -> url -> Application) -> String -> Application
handleWai fromUrl toUrl handler approot =
  \request ->
     do let fUrl = toUrl $ S.unpack $ pathInfo request
        case fUrl of
          (Failure errs) -> return $ Response Status404 [] $ Right $ fromLBS (L.pack $ unlines errs)
          (Success url) -> handler (showString approot . fromUrl) url request

handleWaiU :: (AsURL url) => ((url -> String) -> url -> Application) -> String -> Application
handleWaiU handler approot = handleWai toURL fromURL handler approot
