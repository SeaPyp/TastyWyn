# Implementation Plan: WynTaste Rails Modernization

## Overview

Fresh Rails 8.1 project replacing the legacy Rails 4.2.6 WynTaste app. Builds incrementally: foundation → core models → auth → CRUD controllers → new features (likes, follows, recommendations, scoring, analytics, archival, learning paths, quiz). Each task wires into previous work so there's no orphaned code.

## Tasks

- [x] 1. Generate Rails 8.1 project and configure foundation
  - [x] 1.1 Generate new Rails 8.1 app with PostgreSQL, Propshaft, Importmap
    - Run `rails new wyntaste --database=postgresql --asset-pipeline=propshaft --javascript=importmap` (or configure in-place)
    - Ensure Gemfile targets Ruby 3.4 and Rails 8.1
    - Add `bcrypt`, `faraday`, `rantly` (test group), `kaminari` (pagination) gems
    - Verify `ApplicationRecord` is the base class for all models
    - Configure `database.yml` for PostgreSQL in all environments
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6_

  - [x] 1.2 Set up application layout with flash messages and CSRF protection
    - Enable `protect_from_forgery with: :exception` in `ApplicationController`
    - Create application layout rendering `flash[:notice]` and `flash[:alert]` in a consistent location
    - Ensure all forms include CSRF authenticity token (Rails default)
    - _Requirements: 4.1, 4.2, 10.4_

  - [x] 1.3 Configure routes for all resources
    - Define `resources :users`, `resources :wines`, `resources :posts` with nested `resources :comments, only: [:create, :destroy]`
    - Define session routes: `get '/login', to: 'sessions#new'`, `post '/login', to: 'sessions#create'`, `delete '/logout', to: 'sessions#destroy'`
    - Define `resources :likes, only: [:create, :destroy]`
    - Define `resources :follows, only: [:create, :destroy]`
    - Define `get '/feed', to: 'feed#index'`
    - Define `get '/favorites', to: 'favorites#index'`
    - Define `get '/recommendations', to: 'recommendations#index'`
    - Define `resources :learning_paths, only: [:index, :show]`
    - Define `resources :quizzes, only: [:new, :create, :show]`
    - Define admin namespace with analytics and archivals routes
    - Set `root 'sessions#new'`
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6_

  - [x] 1.4 Set up test helper with Rantly and Minitest configuration
    - Configure `test_helper.rb` with Rantly support
    - Create `test/properties/` directory structure
    - _Requirements: 1.1_

- [x] 2. Checkpoint — Ensure project boots and tests run
  - Ensure `rails db:create` and `rails db:migrate` succeed, `rails test` runs with zero tests, ask the user if questions arise.

- [x] 3. Implement User model, registration, and authentication
  - [x] 3.1 Create User model with migrations and validations
    - Generate User model with `first_name`, `last_name`, `email`, `password_digest`, `expertise_level`, `last_login_at`
    - Add `has_secure_password`
    - Validate email uniqueness (case-insensitive) with `validates :email, uniqueness: { case_sensitive: false }`
    - Validate password minimum length of 5
    - Add `has_many :posts` and `has_many :wines, through: :posts`
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.7, 2.8_

  - [x]* 3.2 Write property tests for User model
    - **Property 1: Case-insensitive email uniqueness**
    - **Property 2: Password minimum length enforcement**
    - **Property 8: Multiple validation errors preservation**
    - **Validates: Requirements 2.3, 2.4, 10.1**

  - [x] 3.3 Implement Authentication concern and SessionsController
    - Create `app/controllers/concerns/authentication.rb` with `current_user`, `logged_in?`, `require_login`
    - Include Authentication concern in `ApplicationController`
    - Implement `SessionsController` with `new`, `create`, `destroy` actions
    - On successful login, set `session[:user_id]` and update `last_login_at`
    - On failed login, re-render form with `flash[:alert]`
    - On logout, reset session and redirect to login
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

  - [x]* 3.4 Write property test for unauthenticated redirect
    - **Property 3: Unauthenticated request redirect**
    - **Validates: Requirements 3.5**

  - [x] 3.5 Implement UsersController with registration flow
    - Implement `new`, `create` actions for registration
    - On valid registration, create user, set session, redirect to welcome page
    - On invalid registration, re-render form with `@user.errors` (not flash) to preserve all validation messages
    - Implement `index`, `show`, `edit`, `update` for user profiles
    - _Requirements: 2.5, 2.6, 10.1, 10.2, 10.3_

  - [x] 3.6 Create User views (registration, login, welcome, profile, index)
    - Create `users/new.html.erb` registration form
    - Create `sessions/new.html.erb` login form
    - Create `users/welcome_user.html.erb` welcome page
    - Create `users/show.html.erb` profile page (will be extended later with follows, likes, learning progress)
    - Create `users/index.html.erb` user listing
    - _Requirements: 2.5, 2.6, 3.1, 3.2_

- [x] 4. Implement Wine model and CRUD
  - [x] 4.1 Create Wine model with migrations and validations
    - Generate Wine model with `name`, `varietal`, `vintage`, `origin`, `description`
    - Validate presence of `name`
    - Add `has_many :posts`, `has_many :users, through: :posts`
    - _Requirements: 5.1, 5.2, 5.3_

  - [x] 4.2 Implement WinesController with all RESTful actions
    - Implement `index`, `show`, `new`, `create`, `edit`, `update`, `destroy`
    - Add scope for browsing by varietal or origin (query params)
    - _Requirements: 5.4, 5.5, 5.6, 5.7, 5.8, 13.3_

  - [x]* 4.3 Write property test for wine filtering
    - **Property 13: Wine filtering correctness**
    - **Validates: Requirements 13.3**

  - [x] 4.4 Create Wine views (index, show, new, edit)
    - Create `wines/index.html.erb` with varietal/origin browse links
    - Create `wines/show.html.erb` displaying all wine attributes (will be extended with Open Wine Data, likes, scores)
    - Create `wines/new.html.erb` and `wines/edit.html.erb` forms
    - _Requirements: 5.4, 5.5, 13.1_

- [-] 5. Implement Post model and CRUD with ActiveStorage
  - [x] 5.1 Create Post model with migrations, validations, and ActiveStorage
    - Generate Post model with `title`, `text`, `rating`, `user_id`, `wine_id`
    - Add `belongs_to :user`, `belongs_to :wine`, `has_many :comments, dependent: :destroy`
    - Add `has_one_attached :image`
    - Validate image content type (JPEG, PNG, GIF only)
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.7_

  - [ ]* 5.2 Write property test for image content type validation
    - **Property 5: Image content type validation**
    - **Validates: Requirements 6.7**

  - [ ] 5.3 Implement Authorization concern
    - Create `app/controllers/concerns/authorization.rb` with `authorize_owner!` method
    - Redirect non-owners with `flash[:alert]` on edit/delete attempts
    - _Requirements: 8.1, 8.2, 8.3_

  - [ ] 5.4 Implement PostsController with all RESTful actions and authorization
    - Implement `index` (ordered by `created_at DESC`), `show`, `new`, `create`, `edit`, `update`, `destroy`
    - Auto-associate post with `current_user` on create
    - Call `authorize_owner!` before edit, update, destroy
    - Any logged-in user can create and view posts
    - _Requirements: 6.6, 6.8, 6.9, 6.10, 8.1, 8.2, 8.3, 8.4, 8.5_

  - [ ]* 5.5 Write property tests for Post ordering and authorization
    - **Property 6: Post listing order invariant**
    - **Property 7: Owner-only post mutation**
    - **Validates: Requirements 6.9, 8.1, 8.2, 8.3**

  - [ ] 5.6 Create Post views (index, show, new, edit, _form)
    - Create `posts/index.html.erb` listing posts by newest first
    - Create `posts/show.html.erb` displaying post with image, comments, and owner-only edit/delete links
    - Create `posts/_form.html.erb` partial with image upload field
    - _Requirements: 6.8, 6.9, 8.1, 8.2_

- [ ] 6. Implement Comment model and nested resource
  - [ ] 6.1 Create Comment model with migrations
    - Generate Comment model with `commenter`, `body`, `post_id`
    - Add `belongs_to :post`
    - Validate presence of `commenter` and `body`
    - _Requirements: 7.1, 7.2_

  - [ ] 6.2 Implement CommentsController (create, destroy) nested under Posts
    - Create comment associated with parent post
    - Redirect to parent post show page after creation
    - _Requirements: 7.3, 7.4_

  - [ ] 6.3 Add comment form and listing to Post show view
    - Add comment form and display existing comments on `posts/show.html.erb`
    - _Requirements: 7.3_

- [ ] 7. Checkpoint — Core CRUD complete
  - Ensure all tests pass for Users, Wines, Posts, Comments. Verify auth, authorization, ActiveStorage uploads, flash messages. Ask the user if questions arise.

- [ ] 8. Implement DrinkLog and usage tracking
  - [ ] 8.1 Create DrinkLog and LoginEvent models with migrations
    - Generate DrinkLog model with `user_id`, `wine_id`, `logged_at`
    - Generate LoginEvent model with `user_id`, `logged_in_at`
    - Add associations to User and Wine models
    - _Requirements: 11.1, 17.1, 17.2_

  - [ ] 8.2 Implement UsageTracker service
    - Create `app/services/usage_tracker.rb`
    - Method to record login events (called from `SessionsController#create`)
    - Method to record drink logs (called from `PostsController#create`)
    - Aggregate query methods for reports (login frequency, posts per user per week, most active users)
    - _Requirements: 17.1, 17.2, 17.3, 17.4, 17.5_

  - [ ] 8.3 Wire UsageTracker into SessionsController and PostsController
    - Call `UsageTracker` to record login event on successful login
    - Call `UsageTracker` to create DrinkLog on successful post creation
    - _Requirements: 11.1, 17.1, 17.2_

  - [ ]* 8.4 Write property tests for DrinkLog and LoginEvent recording
    - **Property 9: DrinkLog creation on post creation**
    - **Property 18: Login event recording**
    - **Property 19: Post creation event recording**
    - **Validates: Requirements 11.1, 17.1, 17.2**

- [ ] 9. Implement Like/Unlike feature
  - [ ] 9.1 Create Like model with migrations and uniqueness constraint
    - Generate Like model with `user_id`, `wine_id`
    - Add unique index on `[user_id, wine_id]`
    - Add `validates_uniqueness_of :wine_id, scope: :user_id`
    - Add associations to User and Wine (`liked_wines`, `liking_users`)
    - _Requirements: 12.1, 12.2, 12.3_

  - [ ]* 9.2 Write property test for like uniqueness
    - **Property 12: Like uniqueness constraint**
    - **Validates: Requirements 12.3**

  - [ ] 9.3 Implement LikesController and FavoritesController
    - `LikesController#create` — like a wine for current user
    - `LikesController#destroy` — unlike a wine
    - `FavoritesController#index` — list current user's liked wines
    - _Requirements: 12.1, 12.2, 12.4, 12.5_

  - [ ] 9.4 Add like/unlike toggle to Wine show page and create favorites view
    - Add like/unlike button on `wines/show.html.erb` reflecting current user's like status
    - Create `favorites/index.html.erb` listing liked wines
    - _Requirements: 12.4, 12.5_

- [ ] 10. Implement Follow/Unfollow and Feed
  - [ ] 10.1 Create Follow model with migrations and constraints
    - Generate Follow model with `follower_id`, `followed_id`
    - Add unique index on `[follower_id, followed_id]`
    - Add check constraint `follower_id != followed_id`
    - Add model validation preventing self-follow
    - Add associations to User (`active_follows`, `passive_follows`, `following`, `followers`)
    - _Requirements: 14.1, 14.2_

  - [ ] 10.2 Implement FollowsController and FeedController
    - `FollowsController#create` — follow a user
    - `FollowsController#destroy` — unfollow a user
    - `FeedController#index` — display posts from followed users ordered by `created_at DESC`
    - _Requirements: 14.1, 14.2, 14.3_

  - [ ]* 10.3 Write property tests for feed and follower counts
    - **Property 14: Feed content and ordering**
    - **Property 15: Follower and following count accuracy**
    - **Validates: Requirements 14.3, 14.5**

  - [ ] 10.4 Update User profile and create feed view
    - Add follower count, following count, follow/unfollow button to `users/show.html.erb`
    - Create `feed/index.html.erb` displaying followed users' posts
    - _Requirements: 14.3, 14.4, 14.5_

- [ ] 11. Checkpoint — Social features complete
  - Ensure all tests pass for likes, follows, feed, drink logs, login events. Ask the user if questions arise.

- [ ] 12. Implement Professional Wine Scoring
  - [ ] 12.1 Create WineScore model with migrations
    - Generate WineScore model with `post_id`, `appearance`, `nose`, `palate`, `overall_impression`, `total_score`
    - Add `belongs_to :post` and `has_one :wine_score` on Post
    - Add validations for sub-score ranges (Appearance: 5–10, Nose: 10–25, Palate: 15–35, Overall Impression: 10–30)
    - _Requirements: 21.1, 21.2, 21.4_

  - [ ] 12.2 Implement WineScoreCalculator service
    - Create `app/services/wine_score_calculator.rb` with weighted calculation logic
    - Weights: Appearance 0.15, Nose 0.25, Palate 0.35, Overall Impression 0.25
    - Normalize sub-scores, apply weights, scale to 50–100 range
    - _Requirements: 21.3_

  - [ ]* 12.3 Write property tests for WineScoreCalculator
    - **Property 27: Wine score weighted calculation**
    - **Property 28: Sub-score range validation**
    - **Validates: Requirements 21.3, 21.4, 21.1**

  - [ ] 12.4 Wire scoring into Post create/edit flow and views
    - Add optional wine score sub-fields to post form
    - Calculate and save `total_score` via `WineScoreCalculator` on create/update
    - Display sub-score breakdown and total on `posts/show.html.erb`
    - Retain simple `rating` field as optional quick-rate alternative
    - _Requirements: 21.2, 21.3, 21.5, 21.6_

- [ ] 13. Implement Recommendation Engine
  - [ ] 13.1 Implement RecommendationEngine service
    - Create `app/services/recommendation_engine.rb`
    - Query user's preferred varietals and origins from posts and likes
    - Return wines not yet reviewed/liked, matching preferred varietals or origins
    - _Requirements: 15.1, 15.2, 15.3_

  - [ ]* 13.2 Write property test for recommendations
    - **Property 16: Recommendation relevance and exclusion**
    - **Validates: Requirements 15.1, 15.2**

  - [ ] 13.3 Implement RecommendationsController and view
    - `RecommendationsController#index` — display recommendations for current user
    - Create `recommendations/index.html.erb`
    - _Requirements: 15.2_

- [ ] 14. Implement Open Wine Data integration
  - [ ] 14.1 Implement OpenWineDataService
    - Create `app/services/open_wine_data_service.rb` using Faraday
    - Fetch enrichment data (tasting notes, grape characteristics, food pairings) by varietal and origin
    - Cache responses with `Rails.cache.fetch` (24-hour expiry)
    - Return `nil` on API failure for graceful fallback
    - _Requirements: 13.2, 13.5, 13.6_

  - [ ] 14.2 Integrate Open Wine Data into Wine show page
    - Call `OpenWineDataService` from `WinesController#show`
    - Display enrichment data (tasting notes, food pairings) when available
    - Display links to Open Wine Data entries for varietal, region, producer
    - Fall back to local attributes only when API data is nil
    - _Requirements: 13.1, 13.2, 13.4, 13.5_

- [ ] 15. Implement Analytics Dashboard
  - [ ] 15.1 Implement Admin::AnalyticsController
    - `index` — overview dashboard
    - `drink_logs` — aggregate wine consumption by varietal, origin, vintage
    - `login_events` — login frequency per user over configurable period
    - `user_activity` — most active users by total actions, posts per user per week
    - Per-user drinking history (wines reviewed, ordered by most recent)
    - _Requirements: 11.2, 11.3, 11.4, 17.3, 17.4, 17.5_

  - [ ]* 15.2 Write property tests for analytics queries
    - **Property 10: Drinking history ordering**
    - **Property 11: Wine popularity ranking**
    - **Validates: Requirements 11.3, 11.4**

  - [ ] 15.3 Create analytics dashboard views
    - Create admin analytics views with consistent table layout
    - Display aggregate data, per-user history, popularity rankings
    - _Requirements: 11.2, 11.3, 11.4, 16.1_

- [ ] 16. Implement Data Presentation Layer (pagination, sorting, empty states)
  - [ ] 16.1 Add pagination to all data listings
    - Integrate Kaminari (or similar) for pagination at 25 records per page
    - Apply to wines index, posts index, users index, analytics tables, favorites, feed
    - _Requirements: 16.3_

  - [ ]* 16.2 Write property test for pagination
    - **Property 17: Pagination size invariant**
    - **Validates: Requirements 16.3**

  - [ ] 16.3 Add column sorting and empty states
    - Add sort-by-column support on data tables (query param based)
    - Add empty-state messages for views with no records
    - Apply consistent visual style (typography, spacing, color) across data views
    - _Requirements: 16.1, 16.2, 16.4, 16.5_

- [ ] 17. Checkpoint — Features complete
  - Ensure all tests pass for scoring, recommendations, Open Wine Data, analytics, pagination. Ask the user if questions arise.

- [ ] 18. Implement User Archival
  - [ ] 18.1 Create ArchivedUser and ArchivalLog models with migrations
    - Generate ArchivedUser model with `original_user_id`, `first_name`, `last_name`, `email`, `password_digest`, `expertise_level`, `last_login_at`, `archived_at`, `original_created_at`
    - Generate ArchivalLog model with `user_id`, `action`, `performed_at`
    - _Requirements: 20.2, 20.6_

  - [ ] 18.2 Implement ArchivalService
    - Create `app/services/archival_service.rb`
    - Archive: move user to `archived_users`, update posts/comments author display to "Archived User", log action — all in a transaction
    - Restore: move archived user back to `users`, log action — all in a transaction
    - Define inactive threshold (default 180 days based on `last_login_at`)
    - Prevent archived users from logging in (check in `SessionsController`)
    - _Requirements: 20.1, 20.2, 20.3, 20.4, 20.5, 20.6_

  - [ ]* 18.3 Write property tests for archival
    - **Property 24: Inactive user archival**
    - **Property 25: Archived user content preservation**
    - **Property 26: Archived user login prevention**
    - **Validates: Requirements 20.1, 20.2, 20.3, 20.4**

  - [ ] 18.4 Implement Admin::ArchivalsController and views
    - `index` — list archived users
    - `create` — trigger archival of inactive users
    - `restore` — restore a specific archived user
    - Create admin archival views
    - _Requirements: 20.2, 20.5_

- [ ] 19. Implement Learning Path
  - [ ] 19.1 Create LearningProgress model with migrations
    - Generate LearningProgress model with `user_id`, `varietal`, `completed_at`
    - Add unique index on `[user_id, varietal]`
    - Add associations to User
    - _Requirements: 19.3, 19.4_

  - [ ] 19.2 Implement LearningPathsController with Open Wine Data integration
    - `index` — display ordered learning path with varietal descriptions from Open Wine Data
    - `show` — detail for a specific varietal step
    - Mark varietal as completed when user has reviewed a wine of that varietal
    - Suggest next varietal based on current progress
    - Fall back to local varietal names when API unavailable
    - _Requirements: 19.1, 19.2, 19.3, 19.5, 19.6_

  - [ ]* 19.3 Write property tests for learning path
    - **Property 22: Learning path completion marking**
    - **Property 23: Next varietal suggestion**
    - **Validates: Requirements 19.3, 19.5**

  - [ ] 19.4 Create learning path views and update user profile
    - Create `learning_paths/index.html.erb` and `learning_paths/show.html.erb`
    - Display user's progress on their profile page
    - _Requirements: 19.2, 19.4_

- [ ] 20. Implement Wine Knowledge Quiz (Stretch Goal)
  - [ ] 20.1 Create QuizAttempt model with migrations
    - Generate QuizAttempt model with `user_id`, `questions` (jsonb), `answers` (jsonb), `score`, `expertise_level`
    - Add associations to User
    - _Requirements: 18.3_

  - [ ] 20.2 Implement QuizService with LLM integration and static fallback
    - Create `app/services/quiz_service.rb`
    - Generate questions via LLM API based on user's expertise level and wine interests
    - Fall back to static question bank (YAML file) when LLM unavailable
    - Calculate score as percentage of correct answers
    - Assign expertise level based on score thresholds
    - Update user's `expertise_level` on profile
    - _Requirements: 18.1, 18.2, 18.4, 18.5, 18.6, 18.7, 18.8_

  - [ ]* 20.3 Write property tests for quiz scoring and expertise assignment
    - **Property 20: Quiz score calculation**
    - **Property 21: Expertise level assignment**
    - **Validates: Requirements 18.4, 18.5**

  - [ ] 20.4 Implement QuizzesController and views
    - `new` — start a quiz
    - `create` — submit answers, calculate score, save attempt
    - `show` — display results with score and expertise level
    - Create quiz views
    - _Requirements: 18.2, 18.4, 18.5, 18.6_

- [ ] 21. Checkpoint — Ensure CSRF token presence across all forms
  - [ ]* 21.1 Write property test for CSRF token presence
    - **Property 4: CSRF authenticity token presence**
    - **Validates: Requirements 4.2**
  - Ensure all tests pass across the entire application. Ask the user if questions arise.

- [ ] 22. Final checkpoint — Full integration verification
  - Ensure all tests pass, all routes resolve, all views render without error. Ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document (Properties 1–28)
- Unit tests validate specific scenarios and edge cases
- The quiz feature (task 20) is a stretch goal and can be deferred
- All service objects are in `app/services/` following Rails conventions
