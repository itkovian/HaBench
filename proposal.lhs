\documentclass[[a4paper]{article}


\usepackage{url}
\usepackage{amsmath}

\title{HaBench: Towards a Standard Haskell Benchmark Suite}
\author{Andy Georges}

%include lhs2TeX.fmt
%include lhs2TeX.sty

\input{remark}
\remarktrue

\begin{document}

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

In this paper, we present a new benchmark suite for Haskell, where we focus on the 
following criteria (in no particular order.

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
Haskell 2010 language standard. Hence, htey can be compiled by most, if not
all, Haskell compilers out there.

\item The benchmarks must be able to scale according to their input set. Also,
it is important there are multiple input sets available, if only to potentially
vary the behaviour of the benchmark by excercising different code paths
throughout the execution.

\end{itemize}


The remainder of this paper is organised as follows ...

\section{Benchmarks}

\subsection{I/O and command line arguments}

To ensure that the benchmarks can be used easily by as many researchers as
possible, each employing their own framework to steer benchmark execution, it
is important that every benchmark in the suite can be called in the same
manner. In our opinion, no benchmark should read from standard input or write
actual results to standard output. Of course, it is perfectly acceptable if a
benchmark writes the occasional message to standard output, but actual results,
e.g., compressed file, should be written to the filesystem. Thus, all files
that contain input to the benchmark must be passed along as arguments on the
command line. As a consequence, command line arguments must be parsed.  There
are many ways to do this, so we should settle on some choice and make sure
people can avoid this boilerplate. The Haskell Wiki has some examples
(\url{http://www.haskell.org/haskellwiki/GetOpt}). \remark{If there are others, please
add.}


\subsection{Use of native libraries}

Hackage has a ton of libraries that provide bindings to native -- C and friends
-- libraries. This has the obvious advantage that Haskell applications can use
fast code, but it results in benchmarks that are not fully written in Haskell.
With the GHC code generation that can deliver excellent code, it should be
possible to use pure Haskell libraries. This has the added advantage that every
enhancement to the Haskell compiler has an immediate effect on the library that
is used by the benchmark. 

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

\section{Input sets}

Preferably, every benchmark has multiple input sets. Ideally, they excercise
different code paths and are sufficiently large to ensure the execution lasts
long enough. 

\section{Critetionifying}



\section{Evaluation}


\section{Conclusion}


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
