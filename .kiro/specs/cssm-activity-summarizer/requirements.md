# Requirements Document

## Introduction

The CSSM Activity Summarizer is a Next.js web application built for a hackathon that consolidates activity data from multiple workplace tools (Slack, Outlook Email, Asana, SFDC, Tableau) into a single outputs page. Users provide input parameters (site addresses, URLs, email addresses) through a web UI, which triggers Amazon QuickSuite (AQS) integrations. AQS handles the actual integrations and consolidates outputs into a database. The app then pulls consolidated data and renders an outputs page with source links and a checkable to-do list. The existing AQS integrations are already built — this project focuses on the Next.js UI, API routes, and output rendering.

## Glossary

- **App**: The CSSM Activity Summarizer Next.js web application
- **Input_Form**: The UI component containing fixed fields for site addresses, URLs, and email addresses
- **API_Router**: The Next.js API route layer that processes user input and communicates with AQS and the database
- **AQS**: Amazon QuickSuite — the existing integration platform that connects to Slack, Outlook Email, Asana, SFDC, and Tableau
- **Database**: The data store where AQS writes consolidated integration outputs
- **Outputs_Page**: The UI page that displays consolidated activity data with source links and to-do list functionality
- **Activity_Item**: A single piece of consolidated data from an integration source, displayed on the Outputs_Page
- **To_Do_Item**: An Activity_Item that can be checked off as completed by the user
- **Source_Link**: A hyperlink on an Activity_Item that navigates to the original source (e.g., Slack message, Asana task, SFDC record)

## Requirements

### Requirement 1: Input Form Rendering

**User Story:** As a CSSM user, I want a form with fixed input fields, so that I can provide the parameters needed to kick off integrations.

#### Acceptance Criteria

1. THE App SHALL render the Input_Form with labeled fields for site addresses, URLs, and email addresses
2. THE App SHALL render SFDC and Tableau input fields as optional, clearly marked as not required
3. WHEN the Input_Form is loaded, THE App SHALL display all input fields in an empty state ready for user entry
4. WHEN a user submits the Input_Form with all required fields populated, THE App SHALL send the input data to the API_Router, including any optional SFDC and Tableau fields if provided
5. IF a user submits the Input_Form with one or more required fields empty, THEN THE App SHALL display a validation message indicating which fields are missing
6. WHEN a user submits the Input_Form without SFDC or Tableau fields, THE App SHALL proceed without triggering those integrations

### Requirement 2: Input Validation

**User Story:** As a CSSM user, I want my inputs validated before submission, so that I can correct mistakes before triggering integrations.

#### Acceptance Criteria

1. WHEN a user enters a value in the URL field, THE App SHALL validate that the value is a well-formed URL
2. WHEN a user enters a value in the email address field, THE App SHALL validate that the value is a well-formed email address
3. IF the Input_Form contains invalid field values, THEN THE App SHALL display field-level error messages describing the validation failure
4. WHILE the Input_Form contains validation errors, THE App SHALL disable the submit button

### Requirement 3: API Route — Trigger AQS Integration

**User Story:** As a CSSM user, I want my input to trigger the AQS integrations, so that activity data is collected from all connected tools.

#### Acceptance Criteria

1. WHEN the API_Router receives valid input data from the Input_Form, THE API_Router SHALL forward the input parameters to AQS
2. WHEN AQS acknowledges receipt of the integration request, THE API_Router SHALL return a success response to the App
3. IF AQS fails to acknowledge the integration request, THEN THE API_Router SHALL return an error response with a descriptive message to the App
4. WHEN the App receives a success response from the API_Router after triggering AQS, THE App SHALL display a confirmation message to the user

### Requirement 4: API Route — Fetch Consolidated Data

**User Story:** As a CSSM user, I want the app to pull consolidated data from the database, so that I can view my activity results.

#### Acceptance Criteria

1. WHEN the Outputs_Page is loaded, THE API_Router SHALL query the Database for consolidated activity data
2. WHEN the Database returns consolidated data, THE API_Router SHALL respond with the Activity_Items to the Outputs_Page
3. IF the Database returns no data, THEN THE API_Router SHALL respond with an empty result and the Outputs_Page SHALL display a message indicating no activity data is available
4. IF the Database query fails, THEN THE API_Router SHALL return an error response and the Outputs_Page SHALL display an error message to the user

### Requirement 5: Outputs Page — Activity Display

**User Story:** As a CSSM user, I want to see my consolidated activity data on a single page, so that I can review all relevant information in one place.

#### Acceptance Criteria

1. WHEN the Outputs_Page receives Activity_Items from the API_Router, THE Outputs_Page SHALL render each Activity_Item with its content and integration source label
2. THE Outputs_Page SHALL display a Source_Link for each Activity_Item that navigates to the original source in a new browser tab
3. THE Outputs_Page SHALL group Activity_Items by integration source (Slack, Outlook Email, Asana, SFDC, Tableau)
4. WHEN the Outputs_Page contains Activity_Items, THE Outputs_Page SHALL display the total count of Activity_Items

### Requirement 6: Outputs Page — To-Do List

**User Story:** As a CSSM user, I want to check off activity items as completed, so that I can track which items I have addressed.

#### Acceptance Criteria

1. THE Outputs_Page SHALL render each Activity_Item as a To_Do_Item with a checkbox
2. WHEN a user checks a To_Do_Item checkbox, THE Outputs_Page SHALL visually mark the To_Do_Item as completed
3. WHEN a user unchecks a completed To_Do_Item, THE Outputs_Page SHALL restore the To_Do_Item to its uncompleted visual state
4. THE Outputs_Page SHALL persist To_Do_Item completion state in the browser so that checked items remain checked on page reload

### Requirement 7: Loading and Status Feedback

**User Story:** As a CSSM user, I want to see loading and status indicators, so that I know the app is working on my request.

#### Acceptance Criteria

1. WHILE the API_Router is processing the AQS trigger request, THE App SHALL display a loading indicator on the Input_Form
2. WHILE the Outputs_Page is fetching Activity_Items from the API_Router, THE Outputs_Page SHALL display a loading indicator
3. WHEN the AQS trigger request completes successfully, THE App SHALL navigate the user to the Outputs_Page or provide a link to it

### Requirement 8: Navigation

**User Story:** As a CSSM user, I want to navigate between the input page and the outputs page, so that I can move through the app workflow.

#### Acceptance Criteria

1. THE App SHALL provide navigation between the Input_Form page and the Outputs_Page
2. WHEN a user navigates to the App root URL, THE App SHALL display the Input_Form page

### Requirement 9: Form Pre-Population

**User Story:** As a CSSM user, if I have completed the form at least once within the last 24 hours, I want my previous entries pre-populated into the form, so that I don't have to re-enter the same information.

#### Acceptance Criteria

1. WHEN a user successfully submits the Input_Form, THE App SHALL store the submitted field values in the browser with a timestamp
2. WHEN a user loads the Input_Form and a previous submission exists within the last 24 hours, THE App SHALL pre-populate all fields with the stored values
3. WHEN a user loads the Input_Form and the most recent stored submission is older than 24 hours, THE App SHALL display all fields in an empty state
4. THE App SHALL allow the user to edit any pre-populated field before submitting

### Requirement 10: Previous Day Activity Categorization

**User Story:** As a CSSM user, I want the output page to divide up a summary of the work I did the day before into customer-facing work and internal work, so that I can clearly see how my time was split.

#### Acceptance Criteria

1. WHEN the Outputs_Page loads, THE App SHALL display a "Previous Day Summary" section showing Activity_Items from the prior calendar day
2. THE Outputs_Page SHALL categorize each previous day Activity_Item as either "Customer-Facing" or "Internal" based on the integration source and activity metadata
3. THE Outputs_Page SHALL display customer-facing and internal Activity_Items in separate, clearly labeled groups within the Previous Day Summary section
4. THE Outputs_Page SHALL display a count of Activity_Items in each category

### Requirement 11 (Stretch): Weekly Activity Summary

**User Story:** As a CSSM user, I want to summarize my activity for the current week, so that I can get a quick overview of what happened.

#### Acceptance Criteria

1. WHEN a user selects the "Summarize my activity this week" option on the Outputs_Page, THE App SHALL request a weekly summary from the API_Router
2. WHEN the API_Router receives a weekly summary request, THE API_Router SHALL query the Database for Activity_Items from the current week and return a summarized view
3. THE Outputs_Page SHALL display the weekly summary in a distinct section separate from the full activity list

---

## Post-Hackathon Evolution

### Requirement 12 (Future): SSO Authentication with Automatic Tool Access

**User Story:** As a CSSM user, I want to log in with my company credentials, so that the app automatically has access to my Slack, SFDC, Email, Asana, and Tableau accounts without me having to manually enter URLs and addresses.

#### Acceptance Criteria

1. THE App SHALL support Single Sign-On (SSO) authentication using the company's identity provider
2. WHEN a user authenticates via SSO, THE App SHALL automatically resolve the user's connected tool accounts (Slack, Outlook Email, Asana, SFDC, Tableau) from their company profile
3. WHEN a user authenticates via SSO, THE App SHALL no longer require the user to manually fill in site addresses, URLs, or email addresses
4. THE App SHALL retain the Input_Form page layout but repurpose it for natural language queries (see Requirement 13)
5. IF SSO authentication fails, THEN THE App SHALL display an error message and offer a fallback to manual input mode

### Requirement 13 (Future): Natural Language Query Interface

**User Story:** As a CSSM user, I want to ask natural language questions about my activity data, so that I can get answers without navigating through pages or filtering manually.

#### Acceptance Criteria

1. THE App SHALL display a natural language input field on the Input_Form page (replacing the manual URL/email fields for authenticated users)
2. WHEN a user submits a natural language query, THE App SHALL interpret the query and fetch relevant data from the connected integrations via AQS
3. THE App SHALL display the query results on the Outputs_Page in a contextual format appropriate to the question asked
4. THE App SHALL support queries such as "What did I work on yesterday?", "Show me my SFDC activity this week", and "How many emails did I send to [customer]?"
5. WHEN the App cannot interpret a query, THE App SHALL display a helpful message suggesting example queries
