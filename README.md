# "Hugs" Market Place

## External Links

| Description                               | Link                                                                              |
| :---------------------------------------- | :-------------------------------------------------------------------------------- |
| Link to the deployed app:                 | TBA                                                                               |
| Link to github repo:                      | https://github.com/evey-pea/hugs.git                                              |
| Planning of Build and Assesment Criteria: | [PLANNING.md](https://github.com/evey-pea/rails-template/blob/master/PLANNING.md) |

## Purpose

The purpose of the hugs marketplace is to enable people who would like a hug to find other people in their area to hug them.

### Why is the problem identified a problem that needs solving?

Whilst there are a large quantity of online marketplaces for human contact, these are mostly based around contact of a sexual nature. There are few online options for those seeking a consensual yet non-sexually motivated hug.

As the project is being prepared during various quarantine levels due to COVID-19 crisis, there  currently is a large number of people who will be somewhat starved of human physical contact
-

The constraints to this problem are largely localisation based profile matching, as prior to meeting for a hug, the persons need to be suitable for each other and within a reasonable proximity to each other.

This is a problem that will provide a unique marketplace opportunity for this to be addressed with a web application.

---

- ["Hugs" Market Place](#hugs-market-place)
  - [External Links](#external-links)
  - [Purpose](#purpose)
    - [Why is the problem identified a problem that needs solving?](#why-is-the-problem-identified-a-problem-that-needs-solving)
  - [Documentation](#documentation)
    - [High-level Components (abstractions)](#high-level-components-abstractions)
    - [Third party services](#third-party-services)
      - [Site deployment](#site-deployment)
      - [Geocoding Services: Google Maps API with Geocoder Rails Gem](#geocoding-services-google-maps-api-with-geocoder-rails-gem)
      - [Image content storage: Amazon S3 Bucket](#image-content-storage-amazon-s3-bucket)
    - [Models Relationships and Database Relations](#models-relationships-and-database-relations)
      - [User model](#user-model)
        - [User sub-model: Blocklist](#user-sub-model-blocklist)
      - [Profile model and data](#profile-model-and-data)
        - [Profile Picture](#profile-picture)
        - [Geospatial Data](#geospatial-data)
      - [Hug Model and Data](#hug-model-and-data)
      - [User to User Messaging](#user-to-user-messaging)
        - [Conversation Model and Data](#conversation-model-and-data)
        - [Messages Model and Data](#messages-model-and-data)
    - [Database ERD and Schema Implementation](#database-erd-and-schema-implementation)
      - [Application database ERD](#application-database-erd)
      - [Schema Implementation](#schema-implementation)
    - [User Stories](#user-stories)
    - [UI Wireframes](#ui-wireframes)
    - [Project Planning and Tracking](#project-planning-and-tracking)

## Documentation


### High-level Components (abstractions)

The high level components required for this app are:

- **User authentication and authorisation** to ensure that users control only their own information *as a user profile* in a reasonably secure manner
  - User account self-management through the Ruby on Rails gem 'Devise'
  - CRUD operations for user profile content  
      -  Data fields
      -  Visibility of profile to other users
      -  'Blocking' unwanted users
- **Internal messaging system** to allow users to interact with each other
- **Searching, sorting and/or filtering capability** based on user profile data and geocoding services. 
- **Storing an image component** for each user (profile picture)

---

### Third party services

#### Site deployment

#### Geocoding Services: Google Maps API with Geocoder Rails Gem

<!-- #TODO Doc: Describe usage of Google Maps API using Geocoder gem-->

#### Image content storage: Amazon S3 Bucket

<!-- #TODO Doc: Describe usage of S3 Bucket -->


---


### Models Relationships and Database Relations

The data base ERD consists of three main model/data areas. Each of these areas relate to three main features of the application: 

- Creating and editing a user profile
  - Nominate a display name
  - Upload a picture to be displayed 
  - Provide user address 
- User to user messaging 
- Search capabiility (with abiility to exclude results of users with have blocked other users) 

Data pertaining to the application is stored within two datasources. These are Postgresql tables and an external data storage source (AWS S3 data bucket). All data tables and fields within the Database ERD are to be assumed to be stored locally by Posetgresql, with the exception of the AWS table.

----

#### User model

The user data is maintained by the 'devise' gem and is the primary source of truth for authenication and referencing all other models within the overall ORM. In all database schema references, on the users table end of the relationship, the user_id of the users table is referenced as being 'one and one only'

Hence the user id field is referenced as a foreign key by the *profile*, *blocklist*, *conversation*, and *message* tables.

The only user supplied data that the 'devise gem' stores is the user's email address and an encrypted copy of their password. 

##### User sub-model: Blocklist

Whilst not having a directly distinct and visible model itself, the *blocklist* table attached to the *user* table is a sub-model of user model. 

It allows for an efficient normalised self-join of user ids for all other queries in the application to reference. Each user can have zero or many entries of users that they have blocked. Each blocklist table entry has a dependent relationship on the user_id from the users table. The entry is only destroyed either by the user requesting it or when the user's account is destroyed.

When the user is blocked by another user, both the users have their information filtered from each other's search results. 

It also is referenced by the messages model to effectively disable their ability in the UI to message each other.

In the UI of the application, the only user who can view a blocklist entry is the user who requested it. This allows for a user to destroy the entry and 'unblock' the formerly blocked user.

----

#### Profile model and data

Since the purpose of the application is to allow users to list their location and hug types for other users, the profile model is the main interaction model for the user. It also seperates the user's authentication data from the data that they wish to be displayed to other users.

Each user has 'one and only one' profile. It is dependent on the user_id of the users table. Whilst there is a method within the model to destroy the profile, this is not made available to the user via the UI. From a UI perspective, the profile is only destroyed whenh the user's account is destroyed.

To assist in providing privacy to the users, no profile information of any user is provided to a user who has not created a profile. Once a user has created an account, they are directed to the profile creation path and are not permitted by the UI to access other parts of the UI until a profile is successfully created.

##### Profile Picture

Whilst not directly stored within the postgresql database, the 'aws-sdk-s3' gem manages the storage of the profile image file by using a cloud bucket container for the file and a reference to it in the profile table.

##### Geospatial Data 

Originally the geospatial data (latitude, longitude) was to be maintined outside of the profile table in a seperate table with its own model in the ORM. But adding it to the 'profile' table enabled the Profile class in the ORM to be extended with the geocoder query methods, reducing code complexity and resulting in less database access with the rails Active Record construct. 

Including the geospatial data in the profile table also permitted the 'geocoder' gem to be called to automatically update the geospatial fields when key address fields (*profile: road, suburb, city, postcode, state, country) are modified. These same fields are required as an input by the 'geocoder' gem as a compacted concatenated string to retrieve the geospatial data.

The 'distance_to' query method of the geocoder gem allows a profile to self reference the profile model and calculate the distance between two addresses in the profile table. This is then passed to the view as an instance variable for viewing in the profile model views.

The 'near' query method enables the Profile model to self reference itself and provide a list of other profiles within a given range. This enables the UI functionality of users to search profiles based on distance.

----

#### Hug Model and Data

----

#### User to User Messaging

User to user messaging is enabled by the interconnected models *conversations* and *messages*. 

Both the conversation and messaging model and database entries are dependent on the *user_id* field in the users table and model. Each user can have zero to many conversations and zero to many messages.

Each model has their own table.

##### Conversation Model and Data

The conversation model and resulting database table is a self-referencing/self-join of the user model. It is used as an abstract reference point to funnel all messages between two users into a single stream.

The conversation model is dependent on both users, referencing the *user_id* of the users table and is only destroyed when both user accounts are destroyed. This enables a conversation to be available to the one remaining user after the other has destroy their account.

Each conversation entry in the database table has a 'none or many' relationship with the messages table. 

##### Messages Model and Data

The messages model is implemented to create and store messages in the database. The group of messages referencing the same *conversation_id*
make up the content of the conversation.

Each message is dependent on the conversation model. For this reason message has 'one and only one' link to objects in the conversation model and table.

The messages model does not have destroy method outside of its dependency relationship. The message entries are only destroyed upon the destruction of conversation entry that they reference. The message entries created by both users are available to both users until both user accounts are destroyed. This allows for the entire conversation to be available to a sole remaining user in the event of one of the users being destroyed.

Each message contains a body of text stored in the *body* field that makes up the message content.

Each message also has a boolean value stored in the *read* field. By default this field is set to 'false'. When the user in the conversation who did not create the message accesses the message for the first time, this flag is then changed by the model to 'true'. The conversation model accesses this value and counts the number of messages that have a 'false' value. This count is then displayed in the UI next to the display name of the user in the list of conversation.

----

### Database ERD and Schema Implementation

#### Application database ERD
![Application database ERD](/docs/Hugs_DB_ERD.png)

#### Schema Implementation

![This is an image of your user stories](This is the relative path to it)

---

### User Stories

<!-- #TODO Doc: 5 User Stories -->
![This is an image of your user stories](This is the relative path to it)

* You also just use normal markdown to describe them
* User stories are well thought out, relevant, and comprehensively cover the needs of the app

---

### UI Wireframes

<!-- #TODO -Doc: 5 (min) Wireframes -->
![This is an image of your wire frames](This is the relative path to it)  
![This is an image of your wire frames](This is the relative path to it)  
![This is an image of your wire frames](This is the relative path to it)  
![This is an image of your wire frames](This is the relative path to it)  
![This is an image of your wire frames](This is the relative path to it)  

* More than five detailed and well designed wireframes provided, for several different screen sizes (as required for the app)

---

### Project Planning and Tracking

Tasks were planned and managed using a checklist in this README.md file and by code tagging with the source files. A regular review of incomplete items was carried out with a VS Code extension called [Todo Tree](https://marketplace.visualstudio.com/items?itemName=Gruntfuggly.todo-tree&ssr=false#overview)

The advantage to using this extension is that it provides a quick way to access parts of the file that are flagged using the code tagging method. A count of the remaining flagged items is also provided to right of each filename contating the tags.

![Todo-Tree extension menu containing files and their code tag counts](/docs/todo-tree-03.png)  

In each of the two examples below, the selected item in the extension's list is also highlighted in the content of the file. Each code tag item also is highlighted in an inverted color for quick syntax reference.

![Overall task list planning in the Toto-Tree extension navigation pane](/docs/todo-tree-01.png)  
***Todo-Tree showing general tasks listed in the README.md file (implemented using hidden code tagging***


![Incomplete checkbox items in the Toto-Tree extension navigation pane](/docs/todo-tree-02.png)  
***Todo-Tree extension showing unchecked items from the README.md file***

Addtional planning 'on the fly' was carried out using a whiteboard next to my desk to mark off tasks as they were implemented and completed.

![Task planning on whiteboard](/docs/whiteboard.jpg)  
***A white board was used to list priorities and map out flow of the application***

