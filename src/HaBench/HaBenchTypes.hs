-- | HaBench module
--
module HaBenchTypes
  ()
  where 

import Data.ConfigFile
import System.IO (FilePath)

-- THOUGHTS
-- specify command line to run benchmark with, for each workload
-- run benchmark in a sandbox directory: "haddock F.hs -o . -d -h > stdout 2> stderr"
-- copy output files we're interested in, remove sandbox
-- specified command line should be useable both by criterion and the benchmark
-- The sandbox should only be built once for all inputs of the benchmarks we
-- are interested in.

-- | Description of a benchmark
data Benchmark = Benchmark 
      { bName :: String           -- ^ Name under which the benchmark is known to the framework
      , bCabalFile :: FilePath    -- ^ The cabal file describing the dependencies and specifics of the benchmark
      , bWorkloads :: [Workload]  -- ^ Descriptions of the workloads that are spawned from this benchmark
      }

-- | Data type synonyms for specifying a workload
type InputSet = [Input]
type ValidOutputFP = FilePath
type OutputSpec = [(FilePath, ValidOutputFP)]

-- | Description of a workload (i.e., a benchmark/input set pair)
data Workload = Workload
      { wInput :: InputSet     -- ^ Description of the inputs consumed by the workload
      , wOutput :: OutputSpec  -- ^ Description of the output produced by the workload
      , wTags :: [WorkloadTag] -- ^ Tags to describe the workload, e.g., if it is cpubound
      }

-- | Tag to classify a workload
data WorkloadTag = CPU | Memory | Compiler

-- | Description of the input types that can be consumed by a workload
-- FIXME: This should be expanded, parameters can take files, etc. So this is not
-- in a usable form right now, I think. I am thinking we need either something
-- either GetOpt or CmdArgs oriented (see proposal). Let's not reinvent hot water,
-- shall we :-)
data Input = InputFile FilePath        -- ^ The input is a file
           | InputParameter Parameter  -- ^ The input is determined by a parameter

-- | Description of a command line parameter
data Parameter = Parameter {
            cmdLineArg :: String,   -- The argument
            value :: ParameterValue --
            }

-- | Description for a value taken by a parameter
data ParameterValue = IntValue Int | StringValue String | None

-- | Potential forms of output produced by a workload run
data Output = Stdout | Stderr | OutputFile FilePath

-- | Type class for workload validators
-- FIXME: This should likely be moved to a different module to keep it clean. Also I do not
-- think the cut can be made this cleanly. Something seems awkward here, namely, not all 
-- precision based validators will operate in the same way. I think we need a type class hierarchy,
-- not necessarily data type instances at this point. The specific validator implementation
-- must be provided by the benchmark implementor, and as such, he must be able to produce e.g.
-- an implementation of a DiffValidator or an implementation of a PrecisionValidator. At this 
-- point it is unclear to me if this should be done here. I guess not.
type ExitCode = Int
type Report = [String]

class Validator a where
  --isValid :: Monad m => a -> m Bool
  isValid :: a -> Workload -> IO (ExitCode, Report) -- ^ Check that the workload produced a valid output

-- | Description of a simple diff'ing validator
data DiffValidator = DiffValidator

instance Validator DiffValidator where
  isValid _ = return . (\v -> if v then (0, []) else (1, [])) . and . map validateOutput . wOutput
      where validateOutput (fp, voFp) = True -- FIXME

-- | Description of a precision-based validator
data PrecisionValidator = PrecisionValidator Double

instance Validator PrecisionValidator where
    isValid (PrecisionValidator p) _ = return (0, []) -- FIXME


