# Implementation Plan: CSSM Activity Summarizer

## Overview

Incrementally build the CSSM Activity Summarizer Next.js app inside `CSSM-Hackathon-Project/`. Start with project scaffolding and pure utility modules (validation, storage, classification), then build API routes, then UI pages, and finally wire everything together. Property-based tests use fast-check; unit tests use Jest.

## Tasks

- [x] 1. Scaffold Next.js project and install dependencies
  - Initialize a Next.js App Router project (JavaScript) in `CSSM-Hackathon-Project/`
  - Install dependencies: `fast-check`, `jest`, `@testing-library/react`, `@testing-library/jest-dom`
  - Create directory structure: `lib/`, `app/`, `app/api/`, `app/outputs/`, `__tests__/`
  - Configure Jest for Next.js (jest.config.js, test setup)
  - _Requirements: 1.1, 8.2_

- [x] 2. Implement validation module
  - [x] 2.1 Create `lib/validation.js` with `validateUrl`, `validateEmail`, `validateRequired`, and `validateForm`
    - `validateUrl`: use URL constructor to check well-formed URLs
    - `validateEmail`: use regex for standard email format
    - `validateRequired`: check non-empty string/array
    - `validateForm`: validate all required fields (siteAddresses, urls, emailAddresses), skip optional fields (sfdcUrl, tableauUrl)
    - Return `{ valid, error? }` for single validators, `{ valid, errors }` for `validateForm`
    - _Requirements: 2.1, 2.2, 2.3, 1.5_

  - [x]* 2.2 Write property test: URL validation correctness
    - **Property 1: URL validation correctness**
    - **Validates: Requirements 2.1**

  - [x]* 2.3 Write property test: Email validation correctness
    - **Property 2: Email validation correctness**
    - **Validates: Requirements 2.2**

  - [x]* 2.4 Write property test: Form validation identifies missing required fields
    - **Property 3: Form validation identifies missing required fields**
    - **Validates: Requirements 1.5**

- [x] 3. Implement localStorage module
  - [x] 3.1 Create `lib/storage.js` with form data and to-do state functions
    - `saveFormData(formData)`: store `{ data, timestamp }` under `cssm-form-data` key
    - `loadFormData()`: return stored data if timestamp < 24h old, else null
    - `isFormDataExpired(timestamp)`: return boolean
    - `saveTodoState(todoState)`: store activity ID → boolean map under `cssm-todo-state` key
    - `loadTodoState()`: return stored map or empty object
    - Handle localStorage unavailability and corrupted JSON gracefully
    - _Requirements: 9.1, 9.2, 9.3, 6.4_

  - [x]* 3.2 Write property test: Form data storage round-trip
    - **Property 9: Form data storage round-trip (within 24 hours)**
    - **Validates: Requirements 9.1, 9.2**

  - [x]* 3.3 Write property test: Form data expiry after 24 hours
    - **Property 10: Form data expiry after 24 hours**
    - **Validates: Requirements 9.3**

  - [x]* 3.4 Write property test: To-do state persistence round-trip
    - **Property 8: To-do state persistence round-trip**
    - **Validates: Requirements 6.4**

- [x] 4. Implement activity classification module
  - [x] 4.1 Create `lib/classification.js` with `classifyActivity`, `categorizeActivities`, and `isFromPreviousDay`
    - `classifyActivity(activity, rules)`: apply rules in order — SFDC → customer-facing, email domain match → customer-facing, customer name mention → customer-facing, fallback → internal
    - `categorizeActivities(activities, rules)`: partition array into `{ customerFacing, internal }`
    - `isFromPreviousDay(activity)`: compare activity.date to prior calendar day
    - Export `DEFAULT_RULES` for configurable classification
    - _Requirements: 10.1, 10.2, 10.3, 10.4_

  - [x]* 4.2 Write property test: Previous day activity filtering
    - **Property 11: Previous day activity filtering**
    - **Validates: Requirements 10.1**

  - [x]* 4.3 Write property test: Activity categorization partitions correctly
    - **Property 12: Activity categorization partitions correctly**
    - **Validates: Requirements 10.2, 10.3, 10.4**

- [x] 5. Checkpoint — Verify utility modules
  - Ensure all tests pass, ask the user if questions arise.

- [x] 6. Implement API routes
  - [x] 6.1 Create `app/api/trigger/route.js` — POST handler
    - Parse request body for siteAddresses, urls, emailAddresses, sfdcUrl, tableauUrl
    - Forward parameters to AQS (exclude SFDC/Tableau when null)
    - Return `{ success: true, message }` on AQS acknowledgment
    - Return 502 with `{ success: false, error }` on AQS failure
    - Set 30-second timeout for AQS call
    - _Requirements: 3.1, 3.2, 3.3, 1.6_

  - [x] 6.2 Create `app/api/activities/route.js` — GET handler
    - Query database for consolidated activity data
    - Return `{ activities, count }` on success
    - Return `{ activities: [], count: 0, message }` when no data
    - Return 500 with `{ success: false, error }` on database failure
    - Never expose stack traces
    - _Requirements: 4.1, 4.2, 4.3, 4.4_

  - [x] 6.3 Create `app/api/summary/route.js` — GET handler (stretch)
    - Accept `?range=week` query param
    - Query database for current week Activity_Items
    - Return `{ summary, range }` on success
    - _Requirements: 11.1, 11.2_

  - [x]* 6.4 Write unit tests for API routes
    - Test trigger route success and error responses
    - Test activities route with data, empty data, and failure
    - Test summary route returns weekly data
    - _Requirements: 3.1, 3.2, 3.3, 4.1, 4.2, 4.3, 4.4, 11.2_

- [x] 7. Implement Input Form page
  - [x] 7.1 Create `app/page.js` with the InputForm component
    - Render labeled fields: site addresses, URLs, email addresses (required); SFDC URL, Tableau URL (optional, clearly marked)
    - Display field-level validation errors using `lib/validation.js`
    - Disable submit button while validation errors exist
    - On submit: call `POST /api/trigger` with form data (include optional fields as null when empty)
    - Show loading indicator while API request is in progress
    - On success: show confirmation message, store form data via `lib/storage.js`, provide link to Outputs Page
    - On error: display error message from API response
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 2.1, 2.2, 2.3, 2.4, 3.4, 7.1, 7.3_

  - [x] 7.2 Add form pre-population from localStorage
    - On mount: call `loadFormData()` — if data exists and not expired, pre-populate all fields
    - If expired or missing: display empty fields
    - Allow editing of pre-populated fields
    - _Requirements: 9.1, 9.2, 9.3, 9.4_

  - [x]* 7.3 Write property test: Form submission data integrity
    - **Property 4: Form submission data integrity**
    - **Validates: Requirements 1.4**

  - [x]* 7.4 Write unit tests for Input Form
    - Test form renders all fields including optional SFDC/Tableau
    - Test validation errors display at field level
    - Test submit button disabled during validation errors
    - Test confirmation message after successful trigger
    - Test loading indicator during API call
    - Test pre-populated fields are editable
    - _Requirements: 1.1, 1.2, 2.3, 2.4, 3.4, 7.1, 9.4_

- [x] 8. Checkpoint — Verify form and API routes
  - Ensure all tests pass, ask the user if questions arise.

- [x] 9. Implement Outputs Page — activity display and to-do list
  - [x] 9.1 Create `app/outputs/page.js` with activity fetching and display
    - Fetch activities from `GET /api/activities` on mount
    - Show loading indicator while fetching
    - Display error message on fetch failure
    - Display "No activity data available" when empty
    - Render each ActivityItem with content, source label, and SourceLink (opens in new tab)
    - Group ActivityItems by integration source (Slack, Outlook Email, Asana, SFDC, Tableau)
    - Display total activity count
    - _Requirements: 4.3, 4.4, 5.1, 5.2, 5.3, 5.4, 7.2_

  - [x] 9.2 Add to-do list functionality
    - Render each ActivityItem as a TodoItem with a checkbox
    - On check: visually mark as completed, persist state via `saveTodoState`
    - On uncheck: restore to uncompleted state, update persisted state
    - On mount: load to-do state from localStorage and apply
    - _Requirements: 6.1, 6.2, 6.3, 6.4_

  - [x]* 9.3 Write property test: Activity rendering completeness
    - **Property 5: Activity item rendering completeness**
    - **Validates: Requirements 5.1, 5.2**

  - [x]* 9.4 Write property test: Activity grouping by source
    - **Property 6: Activity grouping by source**
    - **Validates: Requirements 5.3, 5.4**

  - [x]* 9.5 Write property test: To-do check/uncheck round-trip
    - **Property 7: To-do check/uncheck round-trip**
    - **Validates: Requirements 6.3**

  - [x]* 9.6 Write unit tests for Outputs Page
    - Test to-do checkbox renders for each item
    - Test checking a to-do visually marks it complete
    - Test empty data message displays
    - Test error message displays on failure
    - Test loading indicator during fetch
    - _Requirements: 6.1, 6.2, 4.3, 4.4, 7.2_

- [x] 10. Implement Previous Day Summary section
  - [x] 10.1 Add PreviousDaySummary component to Outputs Page
    - Filter activities using `isFromPreviousDay` from `lib/classification.js`
    - Categorize using `categorizeActivities` into "Customer-Facing" and "Internal" groups
    - Display each category in a clearly labeled group with item count
    - _Requirements: 10.1, 10.2, 10.3, 10.4_

  - [x]* 10.2 Write unit tests for Previous Day Summary
    - Test correct filtering of previous day items
    - Test customer-facing vs internal grouping
    - Test category counts display
    - _Requirements: 10.1, 10.2, 10.4_

- [x] 11. Implement navigation
  - Add a shared navigation component with links between Input Form and Outputs Page
  - Ensure root URL (`/`) renders the Input Form page
  - Add navigation link to Outputs Page after successful form submission
  - _Requirements: 8.1, 8.2, 7.3_

- [x] 12. Checkpoint — Verify full app integration
  - Ensure all tests pass, ask the user if questions arise.

- [x] 13. Implement Weekly Activity Summary (stretch)
  - [x] 13.1 Add WeeklySummary component to Outputs Page
    - Add "Summarize my activity this week" button
    - On click: call `GET /api/summary?range=week`
    - Display weekly summary in a distinct section separate from the full activity list
    - Handle loading and error states inline
    - _Requirements: 11.1, 11.2, 11.3_

  - [x]* 13.2 Write unit tests for Weekly Summary
    - Test button triggers API call
    - Test summary renders in separate section
    - _Requirements: 11.1, 11.3_

- [x] 14. Final checkpoint — Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document
- Unit tests validate specific examples and edge cases
- All project files live in `CSSM-Hackathon-Project/` subfolder
- Stretch goal (Requirement 11) is isolated in task 13 and can be deferred
