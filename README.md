Project WHAM!
======

## About this project
This repository is for all analysis R scripts of the project *"Western Antarctic Peninsula Habitat Mapping"* aka *WHAM!*, my thesis project, where I take images of the bottom of the sea with an ROV and study benthic biodiversity. 
This repository is a "work in progress" of my image analysis workflow, from right after the fieldwork, until end results. You can use these scripts for your own images, wether you record by hand or by an ROV. Below is a detailed explanation of the workflow (wip).

## Gear
I am using a BLUEROV2 from Blue Robotics ("heavy" configuration) equipped with a WaterLinked positionning system, a ping 1D sonar and a GoPro camera that films the bottom. 

## How to use this repository 
Start by cloning this repository. 
Use the following file structure :
```Markdown
wham 
 >wham.Rproj
 >wham-code (this repo)
 >wham-data (not in this repo)
   >campaign
     >dive
     >etc.
```

WORKFLOW
=======

## 1. IMAGE & DATA ACQUISITION
### 1.1 Film bottom with camera
### 1.2 Videos => Still images
1. Download ffmpeg. 
2. Create new folder in dive folder : "campaign_dive.MP4"
2. Put all GOPRO videos of that dive into the folder
3. Copy **ffmpeg** in folder
4. Put QGC video of that dive in the folder
5. Open terminal in folder
```python
.\ffmpeg -i campaign_dive_1.mp4 -r 1 campaign_dive_%03d.png
```
Frequence : 1=1photo par sec. 0.2=1 toute les 5sec, 0.1=1 toute les 10s, 1/60 image%02d.jpg => 1 image par minute [https://superuser.com/questions/135117/how-to-extract-one-frame-of-a-video-every-n-seconds-to-an-image/729351](https://superuser.com/questions/135117/how-to-extract-one-frame-of-a-video-every-n-seconds-to-an-image/729351)
### Outputs of step 1
**GOPRO VIDEO :** GX010195.MP4, GX020195.MP4, GX030195.MP4,…
**QGC VIDEO :** 2022-06-14_14.11.40.mkv
**TELEMETRY :** 2022-02-04-10-24-26.tlog 
**SONAR :** 20220204-195019278.bin 
**IMAGES :** campaign_dive_001.png, campaign_dive_002.png,…

## 2. DATA STORAGE
### 2.1 Store, sort, rename, back-up
Rename all files : "campaign_dive.ext" **except QGC video**
### Outputs of step 2
**GOPRO VIDEO :** campaign_dive_1.MP4, campaign_dive_2.MP4, campaign_dive_3.MP4,…
**QGC VIDEO :** DON’T RENAME
**TELEMETRY :** campaign_dive.tlog 
**SONAR :** campaign_dive.bin 

## 3. IMAGE/DATA PROCESSING
### 3.1 Re-format sonar files 
wham_code>3.1_ping>bin_to_csv.ipynb
### 3.2 Make photomosaic (align images) and extract non-overlapping frames
1. Open **Agisoft Metashape Pro**
2. Add Images>Align…
3. Build Orthophoto
4. Export>frames..
### Outputs of step 3
**SONAR :** "campaign_dive_sonar.csv"
**ORTHOMOSAIC :** "capaign_dive.tif"
**ORTHOPHOTOS :** "campaign_dive-0-1.jpg","campaign_dive-0-2.jpg","campaign_dive-1-2.jpg"

## 4. IMAGE ANNOTATION
### 4.1 Annotation of orthophotos in BIIGLE
[www.biigle.de](https://www.biigle.com)
### 4.2 Download annotation reports 
Request reports > Image annotation report 
- Extended (abundance)
- Area 
- AnnotationLocation
Create a biigle folder in campaign folder and extract .zip files to : 
- wham_data>campaign>biigle>abundance
- wham_data>campaign>biigle>area
- wham_data>campaign>biigle>shp
### 4.3 Rename and convert
In QGIS > import ndjson layer
From layer > Export > Save features as.. > ESRI shapefile
Rename the other files.
### Outputs of step 4
campaign_dive_abundance.xlsx
campaign_dive_area.xlsx
campaign_dive.shp

## 5. FORMATTING
### 5.1 Add cover to annotations
wham.Rproj > wham_code > 5_format > 1-add_cover_to_abundance.R
### 5.2 Convert excel sheets to dataframes
wham.Rproj > wham_code > 5_format > 2-biigle_abundance_to_df.R
### Outputs step 5
A df saved as "campaign_abundance.RData". With all annotations of campaign. Sorted by dive. (for now)

## 6. ANALYSIS
### 6.1 Biodiversity
wham.Rproj > wham_code > 6_analyses > biodiversity.R
### 6.2 BNI - Bayesian Network Inference
wham.Rproj > wham_code > 6_bni >
### 6.3 SPPA - Spatial Point Process Analysis
wham.Rproj > wham_code > 6_analyses > sppa.R
### 6.4 Statistics
## 7. REPORTING
