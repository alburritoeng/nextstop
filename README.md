# nextstop
Next Stop Metrolink iOS Application I created in 2012

# History 
I created this application in 2012 while I would ride the train from Los Angeles to Irvine. 
I remember purchasing a MacBook Pro for the purpose of publishing an iPhone application. At the time, there wasn't a Train Schedule application available on the iTunes store that had the Metrolink schedules. I was paying $300/month for my Metrolink train ticket. I thought that if I could generate at least $150 in sales every month, then I could subsidize my train ticket. 

# Data 
I learned that Metrolink published their train schedules and updated them with any new schedule updates using Google Transit Feed Specification (https://developers.google.com/transit/gtfs). 
I went to Metrolink's website and pulled the data down: https://metrolinktrains.com/globalassets/about/gtfs/gtfs.zip

I learned the format of the data by reading the GTFS specification and began parsing the schedules.

## sqlite
I decided to use sqlite as the data source for the iPhone application. I parsed the *.txt files in the GTFS using a python application ( I can't find the app anymore - it is 2023 and I am just now publishing this Object-C code ) 

# Application
I wrote the application in Objective-C. I'd never written Objective-C before, but I learned. 

# Screen Shots
I don't have any links to the iTunes store post anymore, but I have some images of the application running on iOS below. 
Notice they are 3G! 



![Alt text](img/img5.png?raw=true "Title")

![Alt text](img/img6.png?raw=true "Title")