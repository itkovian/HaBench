\documentclass[[a4paper, preprint]{sigplanconf}


\usepackage{url}
\usepackage{amsmath}


%include lhs2TeX.fmt
%include lhs2TeX.sty

\input{remark}
\remarktrue

\begin{document}

\title{HaBench: Towards a Standard Haskell Benchmark Suite}

\authorinfo{Andy Georges}
           {Ghent University}
           {andy.georges'at'elis.ugent.be}

\maketitle

\section{Introduction}

Benchmarking forms the cornerstone of experimental computer science. Whereas it
can be argued that no set of benchmarks can ever hope to accurately reflect the
behaviour of every application, having a representative set of benchmarks does
allow computer scientists to support claims presented in novel research, for
example, that a new fancy compiler optimisation does yield a significant
performance improvement. Based on the fact that it works for the benchmarks in
the suite, the odds that it will work on an unknown application are quite high,
and indeed, one could expect the claim to hold. 

Recently, functional programming seems to have gained popularity because the
paradigm seems to be a good fit for various challenges the IT industry and
researchers are facing. For example, it is well known that the advent of
multi-core architectures is beneficial to programming languages and paradigms
that allow the programmer to take advantage of the CPU resources in simple, and
preferably, automated ways. In this, functional programming languages, such as
Haskell, definitely have the advantage.
\remark{Add other examples}
Therefore, we focus on the Haskell language.

The {\em nofib} benchmark suite -- which is, incidentally the benchmark suite
of choice for the development of the compiler and runtime system that is most
widely used, namely the Glasgow Haskell Compiler, or GHC for short~\cite{} --
is quite aged, and does in no way reflect the current state-of-the-art in
Haskell programs.  Moreover, on modern hardware, the largest programs in the
suite barely run for more than a few seconds. As these applications rely on a
managed runtime system, the question can be raised wether one is measuring the
runtime system rather than the application~\cite{eeckhout:2003:How}. Following
{\em nofib}, there were several other initiatives, the most recent of which was
based on {\em nofib} and named {\em nobench}. However, this suite suffers from the
same issues as its predecessor.

In this proposal, we present a new benchmark suite for Haskell, where we focus on the 
following criteria (in no particular order).

\begin{itemize}

\item The suite is comprised of several types of benchmarks. The first category
is a set of microbenchmarks, that serve as regression tests for the compiler
and runtime system. These benchmarks should be useful for identifying important
optimisations, garbage collection issues, parallelisation and concurrency
issues, etc. The second type should be comprised of real-world (large)
applications. These should reflect the Haskell ecosystem that is out there, and
contain applications that characterise typical Haskell usage -- even though
Haskell can be used for anything, given that it is Turing complete.
\remark{Simon PJ argued for three categories: imaginary, spectral and real.
That should be OK, if the distiction between imaginary and spectral can be
qualified well.}

\item Ideally, the benchmarks use no compiler extensions and they adhere to the
Haskell 2010 language standard. Hence, they can be compiled by most, if not
all, Haskell compilers out there. Conversely, by requiring that benchmark code
adheres to the Haskell language standard, compiler writers can validate their
tool by verifying the suite is compiled correctly.

\item The benchmarks must be able to scale according to their input set. Also,
it is important there are multiple input sets available, if only to potentially
vary the behaviour of the benchmark by excercising different code paths
throughout the execution.

\end{itemize}


The remainder of this proposal is organised as follows. First we discuss more
in depth the various aspects that have an impact on the implementation and use
of the benchmarks. Next, we discuss the provisions we need to make to allow good 
evaluation practices to be used, i.e., to allow rigorous benchmarking. Third, we 
talk about how we will evaluate the benchmarks and finally we conclude.


\section{Benchmarks}

In this section, we explore more in depth what the requirements are for each
candidate benchmark. We distinguish several areas that are important:
processing of command line arguments, input and output, library code, and
finally, input sets that direct the execution of the benchmark application.


\subsection{Command line arguments}

Typically, non-interactive applications use two methods to steer their
execution. Either they accept command line arguments, or they employ a
configuration file, or a combination of both. Providing command line arguments
seems to allow easier scripting, and it is the method of choice used by most
classical benchmark suites, e.g., SPEC CPU. There are multiple ways to parse
command line arguments in Haskell: ad hoc, by having a fixed ordering of the
arguments, by using a standard library such as {\tt Getopt}. For the latter,
the Haskell wiki describes a number of ways in which this can be done
(\url{http://www.haskell.org/haskellwiki/GetOpt}). 


\subsection{Input and output}


To ensure that the benchmarks can be used easily by as many researchers as
possible, each employing their own framework to steer benchmark execution, it
is important that every benchmark in the suite can be called in the same
manner. Current benchmarks from e.g., the nofib suite use two ways to get data
from their input sets: they either read from standard input (via {\tt
getContents}), redirecting it from a file in the shell, or they actually open a
file containing the relevant data and read that file (via {\tt readfile}).  We
feel there should be a single approach used by all HaBench applications, namely
read the input data from a file, rather than standard input. Likewise, output
should be written to a file, rather than standard output. This has the added
advantage that the output can be compared easily afterward and does not mess up
other useful information that can be printed on the standard output channel,
for example, performance data, execution times, etc. 

How then should the files be read? Traditionally, Haskell offers a {\tt String} type,
essentially a list of {\tt Char}. It has been known for quite some time that the
performance of {\tt String} is less than stellar. Recently, {\tt ByteString} has been added
to the hackage repository, allowing Haskell applications to have good, if not
excellent, functions to read and write data from and to filesi, respectively.
In our opinion, this library should be used.

\remark{This may conflict with the desire to use pure Haskell code, see the next section. Is
ByteString using C underneath?}


\subsection{Use of (native) libraries}

Hackage has a ton of libraries that provide bindings to native -- C and friends
-- libraries. This has the obvious advantage that Haskell applications can use
fast code, but it results in benchmarks that are not fully written in Haskell.
With the GHC code generation that can deliver excellent code, it should be
possible to use pure Haskell libraries. This has the added advantage that every
enhancement to the Haskell compiler has an immediate effect on the library that
is used by the benchmark. 

A second concern is the use of libraries in itself. Benchmarks can used for a
variety of purposes, the first and foremost to gauge the performance of the
code on a given platform, but they can also be used to explore compiler
optiisations, runtime settings, etc. In this light, relying on cabal/hackage to
install libraries may not be the best choice. That would require rebuilding the
libraries on the system time and again, for each set of compiler settings in
such an exploration. Hence, we think it would be best if the benchmark includes
the souce code from the libraries it relies on. On the other hand, this
approach brings about its own issues. Which version to use, keep the source
code in sync with the latest version on Hackage, etc. Can we (ab)use hackage to
host HaBench there and automagically download the sources for any library
dependencies?

\subsection{Micro vs. macrobenchmarks}

There are strong arguments in favour of keeping two different sets of
benchmarks. Microbenchmarks are ideal to excercise different aspects of the
compiler and runtime system. Thus, the suite must comprise a set of
microbenchmarks of which it is known they expose bottlenecks in various parts
of the language platform. However, the goal of benchmarking is to quantify
performance of real systems and for that microbenchmarks fall short of the
mark. HaBench should therefore include real-life applications. Ideally, this
means that typical Haskell use if represented well and that the execution
profiles are sufficiently distinct~\cite{eeckhout:2002:Workload,
hoste:2007:Microarchitecture, phansalkar:2005:Measuring}. 

The use of microbenchmarks relies on the premise that a good execution of the
complete set of microbenchmarks will be reflected in the execution of a
real-world application. More formally, this means that there exists a
sum-operator $\plus$ such that the performance of an actual application $p(A)$
can be expressed in terms of the performance of the microbenchmarks $p(B_i)$ by
some (unknown) complex function $f$, i.e., 

\begin{align*}
p(A) = f(\plus_i \ p(B_i)), i = 1, \ldots, n
\end{align*}

Obviously $f$ will not be straightforward, but its existence seems to be
essential for deciding if the set of microbenchmarks is {\em good} in some
sense.

\subsection{Input sets}

Preferably, every benchmark has multiple input sets. Ideally, they excercise
different code paths and are sufficiently large to ensure the execution lasts
long enough. 

\section{Critetionifying}

Criterion~\cite{} is the library of choice for evaluating the performance of
Haskell code. It is especially useful in the context of short running
applications or functions. However, good benchmarking practice shows that the
approach taken by Criterion is useful at all times, even though one may not
need 100 samples for longer running applications -- 30 might suffice. For this
reason, we deem it necessary that every benchmark is also accesibly through the
(specialised) Criterion main function. In particular, it is vital that the
benchmark's own main function can be called using only standard functionality
available in Haskell and Criterion -- i.e., no hacks to redirect stdin or
stdout, etc. We propose that there be tow main functions present: (i) one that
allows simple command line instatiation of the benchmark, provided the correct
argument are given, and (ii) one that specialised the Criterion main. For
example, in the case of the {\tt anna} benchmark, these might look as follows,
respectively.

\begin{code}
module AnnaMain(main) where

main :: IO ()
main = do
  args <- getArgs
  options <- parseOptions args
  contents <- readFile (input options)
  <snip>
  writeFile (output options) results
\end{code}

and for Criterion, we propose to adhere to the following structure.

\begin{code}
module Main (main) where

import Criterion.Main
import System.Environment

import qualified AnnaMain as B

main = defaultMain [ 
          bgroup "nobench default" 
                 [ bench ("Anna default") $ 
                   whnfIO $ 
                   withArgs [ "--input=big.cor" 
                            , "--output=big.output"
                            ] 
                   B.main]
       ]

\end{code}

\section{Evaluation}

\remark{Here we should discuss the essential characteristics that the
benchmarks exhibit, show that they are covering the space pretty well (e.g., by
using PCA), quantify their performance with different (recent versions) of GHC,
etc.}

\section{Conclusion}

We set out to construct a new Haskell benchmark suite that reflects current
state-of-the-art Haskell programming style. For this, we will design a framework
that is both widely usable and extendible. The benchmarks we will select to be
part of this suite should respect the various criteria we outlined.

\section{Acknowldgements}

\begin{thebibliography}{10}

\bibitem{eeckhout:2002:Workload}
L.~Eeckhout, H.~Vandierendonck, and K. De Bosschere
\newblock Workload Design: Selecting Representative Program-Input Pairs
\newblock PACT 2002, pp. 83-94

\bibitem{eeckhout:2003:How}
L.~Eeckhout, A.~Georges, K.~De Bosschere
\newblock How Java Programs Interact with Virtual Machines at the Microarchitectural Level
\newblock OOPSLA 2003, pp. 169-186

\bibitem{hoste:2007:Microarchitecture}
K.~Hoste, and L.~Eeckhout
\newblock Microarchitecture-Independent Workload Characterization
\newblock IEEE Micro, Special Issue on Hot Tutorials, Vol 27, No 3, pp. 63-72
                   

\bibitem{phansalkar:2005:Measuring}
A.~Phansalkar, A.M.~Joshi, L.~Eeckhout, and L.K. John.
\newblock Measuring Program Similarity: Experiments with SPEC CPU Benchmark Suites
\newblock ISPASS 2005, pp. 10-20
                   


\end{thebibliography}

\end{document}
