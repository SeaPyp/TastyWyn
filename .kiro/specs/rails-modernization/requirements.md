# Requirements Document

## Introduction

This document specifies the requirements for modernizing the WynTaste wine review application from Rails 4.2.6 / Ruby 2.x to Rails 8.1 / Ruby 3.4. The existing application allows users to register, log in, create wine review posts with images, and comment on posts. The modernized application preserves the same domain model (Users, Wines, Posts, Comments) and relationships while adopting modern Rails conventions, fixing known bugs, and replacing deprecated dependencies. No existing data will be migrated; the application starts with a fresh, empty PostgreSQL database.

## Glossary

- **Application**: The WynTaste wine review web application built with Ruby on Rails
- **User**: A registered person with first_name, last_name, email, and password_digest attributes who can create posts and comments
- **Wine**: A wine entry with name, varietal, vintage, origin, and description attributes
- **Post**: A wine review with title, text, image, and rating attributes that belongs to a User and a Wine
- **Comment**: A comment with commenter and body attributes that belongs to a Post
- **Session**: A server-side authentication session identified by a cookie, used to track the currently logged-in User
- **ActiveStorage**: The Rails built-in framework for attaching files to Active Record models, replacing Paperclip
- **ApplicationRecord**: The abstract base class for all models in Rails 5+, replacing direct inheritance from ActiveRecord::Base
- **Propshaft**: The default asset pipeline in Rails 8, replacing Sprockets
- **Importmap**: The Rails 8 default mechanism for managing JavaScript dependencies without a bundler
- **CSRF_Protection**: Cross-Site Request Forgery protection provided by Rails via authenticity tokens
- **Authorization**: The enforcement of rules determining which User can perform which actions on which resources
- **Owner**: The User who originally created a given Post

## Requirements

### Requirement 1: Rails 8.1 Project Foundation

**User Story:** As a developer, I want the application rebuilt on Rails 8.1 with Ruby 3.4, so that the codebase uses a supported, modern framework with current security patches and conventions.

#### Acceptance Criteria

1. THE Application SHALL target Ruby 3.4 and Rails 8.1 in the Gemfile
2. THE Application SHALL use PostgreSQL as the database adapter in all environments
3. THE Application SHALL use Propshaft as the asset pipeline
4. THE Application SHALL use Importmap for JavaScript dependency management
5. THE Application SHALL use ApplicationRecord as the base class for all models
6. THE Application SHALL include bcrypt in the Gemfile for has_secure_password support

### Requirement 2: User Model and Registration

**User Story:** As a visitor, I want to register an account with my name, email, and password, so that I can log in and create wine reviews.

#### Acceptance Criteria

1. THE Application SHALL store User records with first_name, last_name, email, and password_digest attributes
2. THE Application SHALL use has_secure_password on the User model for password hashing via bcrypt
3. WHEN a User registers, THE Application SHALL validate that the email is unique (case-insensitive)
4. WHEN a User registers, THE Application SHALL validate that the password is at least 5 characters long
5. WHEN a User registers with valid attributes, THE Application SHALL create the User record, set the Session to the new User, and redirect to the welcome page
6. WHEN a User registers with invalid attributes, THE Application SHALL re-render the registration form and display all validation error messages without overwriting each other
7. THE User model SHALL declare a has_many association to Post
8. THE User model SHALL declare a has_many association to Wine through Post

### Requirement 3: Session-Based Authentication

**User Story:** As a registered user, I want to log in and log out using my email and password, so that I can access my account securely.

#### Acceptance Criteria

1. WHEN a visitor provides a valid email and password, THE Application SHALL create a Session for that User and redirect to the authenticated landing page
2. WHEN a visitor provides an invalid email or password, THE Application SHALL re-render the login form and display an error flash message
3. WHEN a logged-in User requests to log out, THE Application SHALL destroy the Session and redirect to the login page
4. THE Application SHALL provide a current_user helper method that returns the User associated with the active Session, or nil if no Session exists
5. WHILE no valid Session exists, THE Application SHALL redirect unauthenticated requests to the login page for all actions that require authentication

### Requirement 4: CSRF Protection

**User Story:** As a developer, I want CSRF protection enabled on all form submissions, so that the application is protected against cross-site request forgery attacks.

#### Acceptance Criteria

1. THE ApplicationController SHALL enable CSRF protection by calling protect_from_forgery with the exception-raising strategy
2. THE Application SHALL include a CSRF authenticity token in every HTML form rendered by the Application

### Requirement 5: Wine Model and CRUD

**User Story:** As a logged-in user, I want to create, view, edit, and delete wines, so that I can manage the catalog of wines available for review.

#### Acceptance Criteria

1. THE Application SHALL store Wine records with name, varietal, vintage, origin, and description attributes
2. THE Wine model SHALL declare a has_many association to Post
3. THE Wine model SHALL declare a has_many association to User through Post
4. WHEN a logged-in User submits valid Wine attributes, THE Application SHALL create the Wine record and redirect to the Wine show page
5. WHEN a logged-in User views the wine listing, THE Application SHALL display all Wine records
6. WHEN a logged-in User submits valid updates to a Wine, THE Application SHALL update the Wine record and redirect to the Wine show page
7. WHEN a logged-in User requests to delete a Wine, THE Application SHALL destroy the Wine record and redirect to the wine listing
8. THE WinesController SHALL implement all standard RESTful actions (index, show, new, create, edit, update, destroy)

### Requirement 6: Post Model and CRUD with Image Upload

**User Story:** As a logged-in user, I want to create wine review posts with a title, text, rating, and optional image, so that I can share my wine reviews with other users.

#### Acceptance Criteria

1. THE Application SHALL store Post records with title, text, rating, user_id, and wine_id attributes
2. THE Post model SHALL declare a belongs_to association to User
3. THE Post model SHALL declare a belongs_to association to Wine
4. THE Post model SHALL declare a has_many association to Comment with dependent destroy
5. THE Post model SHALL use ActiveStorage (has_one_attached) for image attachments, replacing Paperclip
6. WHEN a logged-in User creates a Post, THE Application SHALL automatically associate the Post with the current Session User
7. WHEN a logged-in User attaches an image to a Post, THE Application SHALL validate that the image content type is JPEG, PNG, or GIF
8. WHEN a logged-in User submits valid Post attributes, THE Application SHALL create the Post record and redirect to the Post show page
9. WHEN a logged-in User views the post listing, THE Application SHALL display all Post records ordered by creation date descending
10. THE PostsController SHALL implement all standard RESTful actions (index, show, new, create, edit, update, destroy)

### Requirement 7: Comment Model and Creation

**User Story:** As a logged-in user, I want to add comments to wine review posts, so that I can discuss reviews with other users.

#### Acceptance Criteria

1. THE Application SHALL store Comment records with commenter, body, and post_id attributes
2. THE Comment model SHALL declare a belongs_to association to Post
3. WHEN a logged-in User submits a Comment on a Post, THE Application SHALL create the Comment record and redirect to the parent Post show page
4. THE Application SHALL route Comments as a nested resource under Posts

### Requirement 8: Authorization

**User Story:** As a user, I want only the owner of a post to be able to edit or delete that post, so that my reviews cannot be modified by other users.

#### Acceptance Criteria

1. WHILE a User is logged in, THE Application SHALL permit that User to edit only Post records where the User is the Owner
2. WHILE a User is logged in, THE Application SHALL permit that User to delete only Post records where the User is the Owner
3. IF a logged-in User attempts to edit or delete a Post that the User does not own, THEN THE Application SHALL redirect to the Post show page and display an authorization error flash message
4. THE Application SHALL permit any logged-in User to create new Post records
5. THE Application SHALL permit any logged-in User to view all Post records

### Requirement 9: RESTful Routing

**User Story:** As a developer, I want all routes defined using Rails resource routing conventions, so that the routing layer is concise, consistent, and follows Rails standards.

#### Acceptance Criteria

1. THE Application SHALL define User routes using the resources routing helper
2. THE Application SHALL define Wine routes using the resources routing helper
3. THE Application SHALL define Post routes using the resources routing helper
4. THE Application SHALL define Comment routes as a nested resource under Post using the resources routing helper
5. THE Application SHALL define session routes for login (new, create) and logout (destroy) actions
6. THE Application SHALL define a root route that directs to the login page

### Requirement 10: Flash Message Handling

**User Story:** As a user, I want to see clear, accurate feedback messages after actions like registration, login, and form errors, so that I understand what happened.

#### Acceptance Criteria

1. WHEN multiple validation errors occur during User registration, THE Application SHALL display each distinct error message without any message overwriting another
2. WHEN a User successfully creates, updates, or deletes a resource, THE Application SHALL display a success flash notice
3. WHEN an action fails due to validation errors, THE Application SHALL display the relevant error messages to the User
4. THE Application layout SHALL render flash messages (notice and alert) in a consistent location on every page

### Requirement 11: Track and analyze data

**user story:** As a developer I want to be able to track my user data, and see what they are drinking, to give them a better experience

#### Acceptance Criteria
1. THE Application SHALL record a DrinkLog entry each time a User creates a Post, capturing the User, Wine, and timestamp
2. THE Application SHALL provide a developer-facing dashboard that displays aggregate wine consumption data grouped by varietal, origin, and vintage
3. THE Application SHALL display per-User drinking history showing which wines they have reviewed, ordered by most recent
4. THE Application SHALL calculate and display the most popular wines across all Users based on Post count


### Requirement 12: Like/Unlike button

**user story:** As a user, I want to be able to track my favourites and dislikes at the click of a button

#### Acceptance Criteria
1. WHILE a User is logged in, THE Application SHALL permit that User to like any Wine in the catalog
2. WHILE a User is logged in, THE Application SHALL permit that User to unlike a Wine they have previously liked
3. THE Application SHALL prevent a User from liking the same Wine more than once
4. THE Application SHALL display a like/unlike toggle button on each Wine show page reflecting the current User's like status
5. THE Application SHALL permit any logged-in User to view a list of all their liked wines on a dedicated favorites page

### Requirement 13: Learn more about a particular wine

**user story:** As a user I want the ability to learn more about wine, so I can improve my tastes and experiences

#### Acceptance Criteria
1. WHEN a User views a Wine show page, THE Application SHALL display detailed information including name, varietal, vintage, origin, and description
2. THE Application SHALL integrate with the Open Wine Data API to enrich Wine show pages with tasting notes, grape characteristics, and food pairing suggestions
3. THE Application SHALL allow Users to browse wines by varietal or origin to discover similar wines
4. THE Application SHALL display links to the corresponding Open Wine Data entries for the varietal, region, and producer associated with each Wine
5. WHEN the Open Wine Data API is unavailable, THE Application SHALL gracefully fall back to displaying only locally stored Wine attributes without error
6. THE Application SHALL cache Open Wine Data responses to minimize external API calls and improve page load performance

### Requirement 14: Connect with people and see what they are drinking

**user story:** As a user I want the to be able to make friends and see what they're drinking.

#### Acceptance Criteria
1. THE Application SHALL allow a User to follow another User
2. THE Application SHALL allow a User to unfollow a previously followed User
3. WHEN a User views their feed, THE Application SHALL display Posts from followed Users ordered by creation date descending
4. THE Application SHALL provide a User profile page displaying that User's Posts and the wines they have reviewed
5. THE Application SHALL display a follower count and following count on each User profile

### Requirement 15: Build recommendations engine

**user story:** As a user I want to have recommendations based off of the wines I drink

#### Acceptance Criteria
1. THE Application SHALL generate wine recommendations for a User based on the varietals and origins of wines they have reviewed or liked
2. WHEN a User views their recommendations page, THE Application SHALL display a list of wines they have not yet reviewed, ranked by similarity to their preferences
3. THE Application SHALL update recommendations as the User creates new Posts or likes new Wines

### Requirement 16: Data presentation layer

**user story:** As a developer I want gathered data to appear cleanly so I can read it efficiently

#### Acceptance Criteria
1. THE Application SHALL present all tabular data (analytics, user lists, wine catalogs) using a consistent, readable table layout
2. THE Application SHALL support sorting by column on all data tables
3. THE Application SHALL paginate data listings that exceed 25 records per page
4. THE Application SHALL use a consistent visual style (typography, spacing, color) across all data views
5. WHEN a data view contains no records, THE Application SHALL display an empty-state message instead of a blank page

### Requirement 17: Usage data from users

**user story:** As a developer I want to be able to track the frequency and drinking habits of my users.

#### Acceptance Criteria
1. THE Application SHALL record login events with User ID and timestamp
2. THE Application SHALL record Post creation events with User ID, Wine ID, and timestamp
3. THE Application SHALL provide a developer-facing report showing login frequency per User over a configurable time period
4. THE Application SHALL provide a developer-facing report showing the number of Posts created per User per week
5. THE Application SHALL provide a developer-facing report showing the most active Users by total actions (logins + posts + comments + likes) in a given period

### Requirement 18: Test Your Knowledge on Wine, to help understand user level of expertise (Stretch Goal)

**user story:** As a user I want to be able to answer questions, or do a quiz to ascertain my level of skill/knowledge of wine, so that the app can suggest resources based on my level of expertise.

#### Acceptance Criteria
1. THE Application SHALL integrate with an LLM API to dynamically generate wine knowledge quiz questions based on the User's current expertise level and wine interests
2. THE Application SHALL present a quiz consisting of multiple-choice questions generated by the LLM
3. THE Application SHALL store QuizAttempt records with the User, generated questions, selected answers, and score
4. WHEN a logged-in User completes a quiz, THE Application SHALL calculate and display a score
5. THE Application SHALL assign an expertise level (Beginner, Intermediate, Advanced) based on the User's quiz score
6. THE Application SHALL store the User's most recent expertise level on their profile
7. THE Application SHALL use the User's expertise level to influence learning path suggestions (Requirement 19) and wine recommendations (Requirement 15)
8. WHEN the LLM API is unavailable, THE Application SHALL fall back to a set of locally stored static quiz questions

### Requirement 19: Learning progression

**user story:** As a user I want a learning path to make it easier on me - possible wine selections to begin with from each varietal.

#### Acceptance Criteria
1. THE Application SHALL use Open Wine Data grape variety profiles to define a learning path as an ordered sequence of wine varietals with characteristics and suggested starter wines for each
2. THE Application SHALL display the learning path on a dedicated page accessible to logged-in Users, with varietal descriptions and tasting characteristics sourced from Open Wine Data
3. WHEN a User has reviewed a Wine from a varietal in the learning path, THE Application SHALL mark that varietal step as completed for that User
4. THE Application SHALL track and display the User's progress through the learning path on their profile
5. THE Application SHALL suggest the next varietal to explore based on the User's current progress, using Open Wine Data to provide context about the suggested varietal
6. WHEN the Open Wine Data API is unavailable, THE Application SHALL fall back to displaying the learning path with locally stored varietal names and any previously cached descriptions

### Requirement 20: user/wine Database clean up

**user story:** As a developer, I want the ability to "destroy" inactive users into a "castoffs" DB

#### Acceptance Criteria
THE Application SHALL define an inactive User as a User who has not logged in for a configurable period (default: 180 days)
2. WHEN a developer triggers a cleanup operation, THE Application SHALL move inactive User records to an archived_users table
3. THE Application SHALL preserve all Posts and Comments created by an archived User, displaying "Archived User" as the author
4. THE Application SHALL prevent an archived User from logging in
5. THE Application SHALL provide a developer-facing interface to restore an archived User back to the active users table
6. THE Application SHALL log each archive and restore operation with the User ID, action, and timestamp

### Requirement 21: Scoring wines correctly

**user story:** As a user I want to have the option to score the wine professionally, so I can be as accurate as possible

#### Acceptance Criteria
THE Application SHALL support a professional scoring model on Posts using the 100-point wine scoring scale (50–100)
2. WHEN a User creates or edits a Post, THE Application SHALL allow the User to enter sub-scores for Appearance, Nose, Palate, and Overall Impression
3. THE Application SHALL calculate the total score as a weighted sum of the sub-scores
4. THE Application SHALL validate that each sub-score falls within its defined range
5. THE Application SHALL display the breakdown of sub-scores alongside the total score on the Post show page
6. THE Application SHALL retain the existing simple rating field as an optional quick-rate alternative to the professional scoring model

### Requirement 22: Seed Test Account for Local Development

**User Story:** As a developer, I want a pre-seeded test account available after running `db:seed`, so that I can quickly log in and test the application locally.

#### Acceptance Criteria

1. THE Application SHALL include a seed file (`db/seeds.rb`) that creates a test User with first_name "UTest", last_name "Account", email "utest@wyntaste.dev", and password "12345"
2. WHEN a developer runs `rails db:seed`, THE Application SHALL create the test User if it does not already exist
3. THE test User SHALL be able to log in with email "utest@wyntaste.dev" and password "12345"
4. THE seed file SHALL include a comment warning that this account is for local development only and must be removed before deployment
