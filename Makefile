all: hw4.html

hw4.html: hw4.Rmd data/lq.Rdata data/dennys.Rdata
	Rscript -e "library(rmarkdown); render('hw4.Rmd')"
	

data/lq.Rdata: parse_lq.R data/lq/*.html
	Rscript parse_lq.R

data/dennys.Rdata: parse_dennys.R data/dennys/*.html
	Rscript parse_dennys.R
	
data/lq/*.html: get_lq.R
	Rscript get_lq.R
	
data/dennys/*.html: get_dennys.R
	Rscript get_dennys.R
	
clean:
	rm -f hw4.html
	rm -rf data/