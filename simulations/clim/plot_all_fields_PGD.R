library(Rfa)

pgdfilename <- "/dodrio/scratch/projects/2022_200/project_output/RMIB-UGent/vsc45263_wout/DYDOCASE/runs/long/level04/clim/PGD.fa"
x <- FAopen(pgdfilename)
varname_list <- x$list

pdffilename <- paste(pgdfilename, ".pdf", sep="")
pdf(pdffilename)

for (idx in seq_along(varname_list["name"][[1]])) {
    varname <- varname_list["name"][[1]][[idx]]
    y <- try(FAdec(x, varname), silent=TRUE)
    if (!inherits(y, "try-error")) {
        iview(y, legend=TRUE)
    }
}

dev.off()