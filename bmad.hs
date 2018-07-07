

{-# LANGUAGE ExistentialQuantification, RankNTypes, ScopedTypeVariables, LiberalTypeSynonyms #-}


import System.Environment
import Data.Word
import Numeric
import Control.Exception

import qualified Data.Map as M
import qualified Data.ElfEdit as E
import qualified Data.Parameterized.Some as PU
import qualified Data.Macaw.Architecture.Info as AI
import qualified Data.Macaw.Memory as MM
import qualified Data.Macaw.Memory.ElfLoader as MM
import qualified Data.Macaw.Discovery as MD
--import qualified Data.Macaw.Discovery.Info as MD
--module Main where

discoverCode :: E.Elf w -> AI.ArchitectureInfo arch -> (forall ids. MD.DiscoveryFunInfo arch ids -> a) -> a
discoverCode elf archInfo k =
  withMemory MM.Addr64 elf $ \mem ->
      let Just entryPoint = MM.absoluteAddr mem (fromIntegral (E.elfEntry elf))
      in case MD.cfgFromAddrs archInfo mem M.empty [entryPoint] [] of
        PU.Some di -> k di


withMemory :: forall w m a. (MM.MemWidth w, Integral (E.ElfWordType w))
            => MM.AddrWidthRepr w
            -> E.Elf (E.ElfWordType w)
            -> (MM.Memory w -> m a)
            -> m a 
withMemory relaWidth e k =
    case MM.memoryForElf relaWidth e of
        Left err -> error (show err)
        Right (_sim, mem) -> k mem
        
--main :: IO ()
--main = do
--    discoveryCode


