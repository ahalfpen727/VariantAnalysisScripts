idat2lumibatch <- function(filenames) {
  # filenames is a character vector of iDAT filenames
  require(illuminaio)
  require(lumi)
  idatlist = lapply(filenames,readIDAT)
  exprs = sapply(idatlist,function(x) {
    return(x$Quants$MeanBinData)})
  se.exprs = sapply(idatlist,function(x) {
    return(x$Quants$DevBinData/sqrt(x$Quants$NumGoodBeadsBinData))})
  beadNum = sapply(idatlist,function(x) {
    return(x$Quants$NumGoodBeadsBinData)})
  rownames(exprs)=rownames(se.exprs)=rownames(beadNum)=idatlist[[1]]$Quants$CodesBinData
  colnames(exprs)=colnames(se.exprs)=colnames(beadNum)=sapply(idatlist,function(x) {
    return(paste(x$Barcode,x$Section,sep="_"))})
  pd = data.frame(Sentrix=colnames(exprs))
  rownames(pd)=colnames(exprs)
  lb = new("LumiBatch",exprs=exprs,se.exprs=se.exprs,beadNum=beadNum,
    phenoData=AnnotatedDataFrame(pd))
  return(lb)
}
