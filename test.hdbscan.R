source("dirs.R")
if (!exists(file.path(aux.dir, "mylib"))) source(file.path(aux.dir, "mylib.R"))
if (!exists(file.path(aux.dir, "download.bq.R"))) source(file.path(aux.dir, "download.bq.R"))
mylib(c("data.table", "magrittr", "ggplot2", "dbscan", "RColorBrewer", "googledrive"))

Sys.setenv("GCS_DEFAULT_BUCKET" = "helengcs", "GCS_AUTH_FILE" = "~/credentials/helen.key.json")
# mylib("googleCloudStorageR")
# gcs_get_global_bucket()
# # gcloud compute ssh --project [PROJECT_ID] --zone [ZONE] [INSTANCE_NAME]

# # download.bq(sql, "dataanalyst-188909")
# temp <- tempfile(fileext = ".zip")
# # download.file("https://drive.google.com/uc?id=1PgdgBGFRvlTsdw57lebqpEQLfp8J8Xx_&export=download", temp)
# dl <- drive_download(
#     as_id("1PgdgBGFRvlTsdw57lebqpEQLfp8J8Xx_"), path = temp, overwrite = TRUE)
# out <- unzip(temp, exdir = tempdir())
# file.copy(out, "data/raw_input/")

dt.raw <- fread("data/raw_input/dt_rent_path.csv")
dt.raw <- dt.raw[!(rent_lat==0|return_lat==0)]
dt.raw[rent_lng<0, rent_lng:=abs(rent_lng)]
dt.raw <- dt.raw[rent_lat>24.75 & rent_lng>121.4 & rent_lng < 121.65 & rent_lat < 25.15]
dt.raw <- dt.raw[return_lat>24.75 & return_lng>121.4 & return_lng < 121.65 & return_lat < 25.15]

yn <- 100
# xn <- yn/2
xn <- yn
# colors <- c("#FFFFCC","#FFEDA0","#FED976","#FEB24C","#FD8D3C","#FC4E2A","#E31A1C","#BD0026","#800026")
colors <- brewer.pal(uniqueN(class.num$log)+4, "OrRd")[c(2, 4, 6, 7, 9)]

for (var in c("rent", "return")) {
  target.var1 <- quote(sprintf("%s_lat", var))
  target.var2 <- quote(sprintf("%s_lng", var))
  dt.raw[, `:=` (lat_class=cut(get(eval(target.var1)), yn, 
                               labels = seq(from=min(get(eval(target.var1))), 
                                            to=max(get(eval(target.var1))), 
                                            length.out = yn)+((max(get(eval(target.var1)))-min(get(eval(target.var1))))/(yn*2))
                               ),
                 lng_class=cut(get(eval(target.var2)), xn, 
                               labels = seq(from=min(get(eval(target.var2))), 
                                            to=max(get(eval(target.var2))), 
                                            length.out = xn)+((max(get(eval(target.var2)))-min(get(eval(target.var2))))/(xn*2))
                               )
                 )]
  class.num <- dt.raw[, .N, by=.(lat_class, lng_class)][N>5]
  setorder(class.num, -N)
  # View(class.num)
  # dt.raw[, .(summary(rent_lat-24), summary(rent_lng-121))]
  # plot.ecdf(class.num$N)
  # class.num[, high:=N>500]
  class.num[, log:=cut(N, c(min(N)-1, 1000, 2000, 3000, 4000, max(N)), dig.lab=5, labels = 1:5)]
  # ggplot(dt.raw, aes(x=rent_lng, y=rent_lat)) + geom_point()

  # ggplot(class.num, aes(x=lng_class, y=lat_class, color=log)) + geom_point() +
  #   scale_color_manual(values = colors, name=sprintf("# %s", var)) +
  #   theme_void() +   theme(
  #     panel.background = element_rect(fill = "transparent"), # bg of the panel
  #     plot.background = element_rect(fill = "transparent", color = NA), # bg of the plot
  #     panel.grid.major = element_blank(), # get rid of major grid
  #     panel.grid.minor = element_blank(), # get rid of minor grid
  #     legend.background = element_rect(fill = "transparent",) # get rid of legend bg
  #     # legend.box.background = element_rect(fill = "transparent") # get rid of legend panel bg
  #   )
  # filename <- sprintf("%s_grid.png", var)
  # ggsave(filename, width=10, height=9, bg = "transparent")
  # # gcs_upload(name=filename)
  # # system(sprintf("gsutil -m cp %s/%s gs://helengcs", getwd(), filename))
  # # mylib("googledrive")
  # drive_upload(filename)
  fn <- sprintf("%s_grid.csv", var)
  write.csv(class.num, fn, row.names = F)
  drive_upload(fn)
}

# class <- class.num[N<500]
# class[, sum(N)]
# ggplot(class.num, aes(x=lng_class, y=lat_class, color=high)) + geom_point()
# # class <- data.table()
# dt.new <- dt.raw[class, on=c("lat_class", "lng_class")]
# dt <- dt.new
# target.data <- dt[, .(rent_lng, rent_lat)]
# plot(target.data, pch=20)
# res <- hdbscan(target.data, minPts = 50)
# res
# plot(target.data, col=res$cluster+1, pch=20)
# 
# ggplot(dt, aes(x=rent_lng, y=rent_lat)) + geom_point()
# 
# set.seed(372)
# idx <- sample.int(nrow(dt.new), 10000)
# dt <- dt.new[idx]
# ggplot(dt, aes(x=rent_lng, y=rent_lat)) + geom_point()
# 
# set.seed(372)
# idx <- sample.int(nrow(dt.raw), 10000)
# dt <- dt.raw[idx]
