all: proposal.lhs
	lhs2TeX proposal.lhs > proposal.tex
	pdflatex proposal.tex
	pdflatex proposal.tex

