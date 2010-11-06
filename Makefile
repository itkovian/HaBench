all: HaBench

proposal: proposal.lhs
	lhs2TeX proposal.lhs > proposal.tex
	pdflatex proposal.tex
	pdflatex proposal.tex

HaBench: HaBench.hs
	ghc --make HaBench.hs -o HaBench
