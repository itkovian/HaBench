module HaBench where 

import System.IO (FilePath)

-- data type for a benchmark
data Benchmark = Benchmark {
            bName :: String,
            bCabalFile :: FilePath, -- delivers version, dependencies, author, ...
            bWorkloads :: [Workload]
            }

-- data type for a workload (benchmark/input set pair)
type InputSet = [Input]
type ValidOutputFP = FilePath
type OutputSpec = [(FilePath, ValidOutputFP)]
data Workload = Workload {
        wInput :: InputSet,
        wOutput :: OutputSpec,
        wTags :: [WorkloadTag]
}

data WorkloadTag = CPU | Memory | Compiler

-- data type for part of the input set for a workload
data Input = InputFile FilePath
           | InputParameter Parameter

data Parameter = Parameter {
            cmdLineArg :: String,
            value :: ParameterValue
            }

data ParameterValue = IntValue Int | StringValue String | None

-- data type for output files
data Output = Stdout | Stderr | OutputFile FilePath

-- type class for workload validators
class Validator a where
    --isValid :: Monad m => a -> m Bool
    isValid :: a -> Workload -> IO Bool

-- simple diff validator
data DiffValidator = DiffValidator
instance Validator DiffValidator where
    isValid _ = return . and . map validateOutput . wOutput
             where
        validateOutput (fp, voFp) = True -- FIXME

-- precision validator
data PrecisionValidator = PrecisionValidator Double
instance Validator PrecisionValidator where
    isValid (PrecisionValidator p) _ = return True -- FIXME

-- dummy main
main = putStr "HaBench"
