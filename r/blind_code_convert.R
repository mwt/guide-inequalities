MATLAB_FOLDER <- file.path("..", "octave")
if (!dir.exists("1_functions")) {
  dir.create("1_functions")
}

hMaps <-
  makeFuncMaps(pathDict = system.file("extdata", "HiebelerDict.txt", package = "matconv"))

source(system.file("extdata", "defDataConv.R", package = "matconv"))

matlab_files <- list.files(path = MATLAB_FOLDER,
                           pattern = "\\.m$",
                           recursive = TRUE)

for (matlab_file in matlab_files) {
  mat2r(
    file.path(MATLAB_FOLDER, matlab_file),
    pathOutR = `substr<-`(
      x = matlab_file,
      nchar(matlab_file),
      nchar(matlab_file),
      value = "R"
    ),
    funcConverters = hMaps,
    dataConverters = dataConvs,
    verbose = 1
  )
}
