# TouchlessTravelApp
Stuttgart Hackathon 2015 iOS App - Team Hackerstolz and Friends

[Stuttgart Hackathon] (http://www.hackathon-stuttgart.de/home2015/)

### Elevator Pitch
Create a real pay-as-you go solution: No more tickets, no more terminals, no more queues.
Touchless Travel is the world's first approach that leverages iBeacon technology to track public transport rides. 
With the help of iBeacons your phone recognizes the vehicle when you enter and leave, thus being able to infere the distance traveled. There is no user interaction required. 

At the end of the month all rides are accumulated and the app proposes the cheapest ticket option depending on your actual usage of public transportation. For example the app would propose a monthly ticket if you did many rides.

### Facts

- ~ 10 billion (10^9) passengers per year use public transport (ÖPNV) in Germany.
- ~ 60.000 buses and trains (S-Bahnen) in german public transport.
- Costs per iBeacon < 1$ when bought on a larger scale.


### Target Group

B2C: Everybody who uses public transport

B2B: Local public transport providers, taxi companies, train operators


### Technology 

1. iBeacons + end user smartphone app - Native iOS app (Swift), detecting entering and leaving of public transportation. The app also displays a travel history including fare calculation.
2. Cloud infrastructure - Scala and play framework based cloud server hosted on Heroku. It stores rides data and provides an API to integrate further systems. E.g. the public transport providers ERP systems for billing.
3. Ticket inspectors App - Scan QR codes to verify that users checked in correctly.
4. Analytics webapp - HTML5/CSS/JS webapp for public service providers to monitor the usage of vehicles in realtime.

The following figure visualizes the systems architecture:

![architecture](/readme_images/architecture.png)


### Show me something!

[Intro](https://touchless-travel.herokuapp.com/webapp/intro.html)

[Landing Page + Map](http://touchless-travel.herokuapp.com/webapp/index.html)

![screenshot](/readme_images/screenshot.png)
<img src="/readme_images/app_idle.png" width="285"/> <img src="/readme_images/app_ticket.png" width="285"/> <img src="/readme_images/app_report.png" width="285"/> 

### Related Git Repositories

[Server](https://github.com/hackerstolz/touchless-travel/)


### Team

- Theresa Best
- Michael Dell
- Jascha Quintern
- Sophie Ettl
- Daniel Zaske
- Philip Zaske
- Norman Weisenburger
