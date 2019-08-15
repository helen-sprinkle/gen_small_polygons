source("dirs.R")
if (!exists(file.path(aux.dir, "mylib"))) source(file.path(aux.dir, "mylib.R"))
if (!exists(file.path(aux.dir, "download.bq.R"))) source(file.path(aux.dir, "download.bq.R"))
mylib(c("data.table", "magrittr", "ggplot2", "dbscan"))

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

yn <- 100
xn <- yn/2
dt.raw[, `:=` (lat_class=cut(rent_lat, yn, labels = 1:yn), lng_class=cut(rent_lng, xn, labels = 1:xn))]
class.num <- dt.raw[, .N, by=.(lat_class, lng_class)]
setorder(class.num, -N)
# View(class.num)
# dt.raw[, .(summary(rent_lat-24), summary(rent_lng-121))]
# plot.ecdf(class.num$N)
class.num
# ggplot(dt.raw, aes(x=rent_lng, y=rent_lat)) + geom_point()

class <- class.num[1]
class[, sum(N)]
# ggplot(class.num[N<200], aes(x=lng_class, y=lat_class)) + geom_point()
# class <- data.table()
dt.new <- dt.raw[class, on=c("lat_class", "lng_class")]
dt <- dt.new
target.data <- dt[, .(rent_lng, rent_lat)]
plot(target.data, pch=20)
res <- hdbscan(target.data, minPts = 10)
res
plot(target.data, col=res$cluster+1, pch=20)

ggplot(dt, aes(x=rent_lng, y=rent_lat)) + geom_point()

set.seed(372)
idx <- sample.int(nrow(dt.new), 10000)
dt <- dt.new[idx]
ggplot(dt, aes(x=rent_lng, y=rent_lat)) + geom_point()

set.seed(372)
idx <- sample.int(nrow(dt.raw), 10000)
dt <- dt.raw[idx]
