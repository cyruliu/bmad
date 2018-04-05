

{-# LANGUAGE ExistentialQuantification, RankNTypes, ScopedTypeVariables, LiberalTypeSynonyms #-}

import System.Environment
import qualified Data.Map as M
import Data.Word
import qualified Data.ElfEdit as E
import qualified Data.Parameterized.Some as PU
import qualified Data.Macaw.Architecture.Info as AI
import qualified Data.Macaw.Memory as MM
import qualified Data.Macaw.Memory.ElfLoader as MM
import qualified Data.Macaw.Discovery as MD
--import qualified Data.Macaw.Discovery.Info as MD

main :: IO ()
main = cfg


discoverCode :: E.Elf Word64 -> AI.ArchitectureInfo X86_64 -> (forall ids . MD.DiscoveryFunInfo X86_64 ids -> a) -> a
discoverCode elf archInfo k =
  withMemory MM.Addr64 elf $ \mem ->
      let Just entryPoint = MM.absoluteAddrSegment mem (fromIntegral (E.elfEntry elf))
      in case MD.cfgFromAddrs archInfo mem M.empty [entryPoint] [] of
        PU.Some di -> k di

{-
 withMemory :: forall w m a . (MM.MemWidth w, Integral (E.ElfWordType w))
            => MM.AddrWidthRepr w
            -> E.Elf (E.ElfWordType w)
            -> (MM.Memory w -> m a)
            -> m a 
withMemory relaWidth e k =
    case MM.memoryForElfSegments relaWidth e of
        Left err -> error (show err)
        Right (_sim, mem) -> k mem
        
-}


