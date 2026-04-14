class Strings {
  //GENERIC
  static const String retry = 'Retry';
  static const String add = "Add";
  static const String create = "Create";
  static const String reset = "Reset";
  static const String name = "Name";
  static const String confirm = "Confirm";
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String undo = 'Undo';
  static const String save = 'Save';
  static const String user = "User";
  static const String search = 'Search';
  static const String description = 'Description';
  static const String noSearchFound = 'Nothing found...';
  static const String thanksFeedback = 'Thanks for your feedback!';
  static const String continue_ = "Continue";
  static const String back = "Back";
  static const String noCredits = "Not enough credits";
  static const String text = "Text";
  static const String info = "Additional info";
  static const String write = "Write";
  static const String execute = "Execute";
  static const String cronExpression = "Cron expression";
  static const String timezone = "Timezone";
  static const String openAppSettings = "Open app settings";
  static const String error = "Error";
  static const String file = "File";
  static const String googleDriveNotImplemented =
      "Google Drive credentials creation not implemented yet on mobile, please use the web platform to create the credential";
  //PROFILE
  static const String browseGallery = "Browse device gallery";
  static const String takePhoto = "Take photo";
  static const String organization = "Organization";
  //SUBSCRIPTION
  static const String credits = "Credits";
  //ASSISTANTS
  static const String tag = "Mention other agents";
  static const String visibilityUser = "Visibility: User";
  static const String visibilityOrganization = "Visibility: Organization";
  static const String imagesReading = "Images reading";
  static const String video = "Video";
  static const String audio = "Audio";
  static const String messageAbbreviation = "msg";
  static const String expand = "Expand";
  static const String collapse = "Collapse";
  //CHAT
  static const String newConversation = 'New Conversation';
  static const String history = 'History';
  static const String editTitle = 'Edit title';
  static const String insertTitle = 'Insert title';
  static const String dialogDeleteConversation =
      'Are you sure you want to delete this conversation?';
  static const String dontAskAgain = 'Don\'t ask again';
  static const String deleted = 'Deleted';
  static const String message = 'Message';
  static const String references = 'References';
  static const String like = 'Like';
  static const String dislike = 'Dislike';
  static const String copy = 'Copy';
  static const String use = 'Use';
  static const String copiedClipboard = 'Copied to clipboard';
  static const String searchExternalSource = 'Search in external sources';
  static const String read = "Read";
  static const String rateConversation = "Rate Conversation";
  static const String rateConversationFlavor =
      "Are you satisfied by your agent's responses? Leave a comment to help me improve";
  static const String leaveComment = "Leave a comment (optional)";
  static const String conversationRate1 = "Completely unsatisfied";
  static const String conversationRate2 = "A little satisfied";
  static const String conversationRate3 = "Quite satisfied";
  static const String conversationRate4 = "Very satisfied";
  static const String conversationRate5 = "Completely satisfied";
  static const String rated = "Rated";
  static const String webSearch = "Web Search";
  static const String webSearchInfo =
      "This option allows you to enable the Web Search for the agent. With the Web Search enabled, the user can enable the agent to perform Web Searches autonomously in function of the topic being discussed.";
  static const String webSearchInfoShort =
      "With the Web Search enabled the agent can perform Web Searches autonomously in function of the topic being discussed.";
  static const String page = "page";
  static const String fileDownloadSuccess = "File downloaded successfully!";
  static const String fileDownloadFail = "File download failed!";
  static const String creditsEndedTitle =
      "Oops! Looks like you've run out of credits to send new messages";
  static const String creditsEndedText =
      "If you want to buy more credits and continue the conversation or want to subscribe to a new subscription, click on the button below";
  static const String attachment = "Attachment";
  static const String attachmentUploadSuccess =
      "Attachment uploaded successfully!";
  static const String attachmentUploadSuccessMultiple =
      "Attachments uploaded successfully!";
  static const String attachmentUploadFailed = "Attachment upload failed!";
  static const String attachmentTrimmingSnackbar =
      "To respect context limits, some attachments were reduced.";
  static const String attachmentTrimmingDetailBoth =
      "@truncated truncated, @removed removed.";
  static const String attachmentTrimmingDetailTruncated =
      "@truncated truncated.";
  static const String attachmentTrimmingDetailRemoved = "@removed removed.";
  static const String attachmentTrimmingTitle = "Attachment trimming";
  static const String emergencyTrimmingTitle = "Emergency trimming";
  static const String attachmentTrimmingEstimatedTokens = "Est. tokens";
  static const String attachmentTrimmingTokensDetail =
      "Context tokens (approx.): @before before → @after after · @saved saved";
  static const String attachmentTrimmingReasonProportionalShare =
      "Proportional reduction";
  static const String attachmentTrimmingReasonFallbackOverBudget =
      "Removed (over context limit)";
  static const String attachmentTrimmingReasonOverBudget =
      "Over context limit";
  static const String attachmentTrimmingReasonBelowMinUseful =
      "Below minimum useful";
  static const String contextResources = "Context Resources";
  static const String addResource = "Add Resource";
  static const String totalResources = "Total active resources";
  static const String totalResourcesFlavor =
      "Every message will use at least this much tokens. Each message includes 2000 tokens.";
  static const String contextResourcesInfo =
      "Here you will find the attachments that you have added to the conversation and that will be used to answer your questions. You can choose to include or exclude each attachment in every message.";
  static const String costs = "Costs";
  static const String send = "Send";
  static const String submit = "Submit";
  static const String stop = "Stop";
  static const String improveResponse = "Improve response";
  static const String context = "Context";
  static const String userQueryTokens = "User Query Tokens";
  static const String outputTokens = "Output Tokens";
  static const String nerdsStats = "Nerds Stats";
  static const String hide = "Hide";
  static const String show = "Show";
  static const String anonymous = "Anonymous";
  static const String anonymousSession = "Anonymous Session";
  static const String anonymousConversation = "Anonymous Conversation";
  static const String anonymousSessionInfo =
      "An anonymous session is being started. Once started, the session will be deleted after 15 minutes of inactivity and the information will be encrypted with a key generated at the time of creation. Exiting the conversation will result in loss of access to the session and its subsequent deletion.";
  static const String anonymousConversationsNotAllowed =
      "Anonymous conversations are not allowed for this agent";
  static const String searchingTheWeb = "Searching the web";
  static const String sources = "Sources";
  static const String media = "Media";
  static const String relatedSearches = "Related Searches";
  static const String browseDevice = "Browse device";
  static const String device = "Device";
  static const String report = "Report";
  static const String reportFeedback =
      "Thank you for your report! We will analyze it as soon as possible";
  static const String fork = "Continue from here";
  static const String forkTitle = "Continue conversation from here";
  static const String editMessageTitle = "Edit message";
  static const String editMessageDescription =
      "Edit this message and keep all messages before it.";
  static const String forkDescription =
      "You will create a copy of this conversation ending with this message. This conversation will remain untouched. Do you want to continue?";
  static const String newConversationTitle = "New conversation title";
  static const String newConversationCreated = "New conversation created!";
  static const String resourceDeletedSuccess = "Resource deleted successfully!";
  static const String resourceDeleteConfirm =
      "Are you sure you want to delete this resource: ";
  static const String documents = "Documents";
  static const String databases = "Databases";
  static const String database = "Database";
  static const String columns = "Columns";
  static const String images = "Images";
  static const String generatedImages = "Generated Images";
  static const String links = "Links";
  static const String noResourcesFound = "No resources found...";
  static const String news = "News";
  static const String location = "Location";
  static const String position = "Position";
  static const String memoryProfiles = "Memory Profiles";
  static const String noVisionCapability =
      "This agent has no Vision Capabilities, you can Tag an agent that has vision capabilities like Pixtral or Claude Sonnet 3.7";
  static const String retryWith = "Retry with";
  static const String whatDoYouSee = "What do you see?";
  static const String doubleTapToShowMoreOptions =
      "Double tap to show more options!";
  static const String customActions = "Custom actions";
  static const String openDrawer = "Open drawer";
  static const String customActionsDisabled =
      "Custom actions are disabled until the agent has finished responding";
  static const String createNote = "Create a note";
  static const String editNote = "Edit note";
  static const String noteName = "Note name";
  static const String noteHint = "Write your note...";
  static const String seeAll = "See all";
  static const String own = "Own";
  static const String filter = "Filter";
  static const String filterConversations = "Filter conversations";
  static const String applyFilters = "Apply filters";
  static const String clearFilters = "Clear filters";
  static const String unrated = "Unrated";
  static const String toDateBeforeFromDate =
      "This date must be after the starting date";
  static const String showFullMessage = "Show full message";
  static const String results = "results";
  static const String showing = "Showing";
  static const String of = "of";
  static const String query = "Query";
  static const String searchEngine = "Search Engine";
  static const String country = "Country";
  static const String pageNumber = "Page number";
  static const String noKbFound = "No data found in the knowledge base";
  static const String documentDeleted = "Document deleted";
  static const String documentsManaged = "Documents managed";
  static const String documentGetSuccess = "Document retrieved successfully";
  static const String documentCreateSuccess = "Document created successfully";
  static const String documentDeleteSuccess = "Document deleted successfully";
  static const String documentListSuccess = "Documents listed successfully";
  static const String documentUpdateSuccess = "Document updated successfully";
  static const String documentTextInsertSuccess = "Text inserted successfully";
  static const String documentTextReplaceSuccess = "Text replaced successfully";
  static const String documentTextDeleteSuccess = "Text deleted successfully";
  static const String documentExportPdfSuccess = "PDF exported successfully";
  static const String documentExportDocxSuccess = "DOCX exported successfully";
  static const String documentOperationFailed =
      "Error executing document operation";
  static const String subject = "Subject";
  static const String toEmail = "To£";
  static const String ccEmail = "Cc";
  static const String bccEmail = "Bcc";
  static const String body = "Body";
  static const String thinking = "Thinking...";
  static const String noScreenshotAvailable = "No screenshot available";
  static const String executionTime = "Execution time";
  static const String time = "Time";
  static const String language = "Language";
  static const String success = "Success";
  static const String failed = "Failed";
  static const String result = "Result";
  static const String code = "Code";
  static const String output = "Output";
  static const String errors = "Errors";
  static const String noOutput = "No output";
  static const String noCodeProvided = "No code provided";
  static const String seconds = "seconds";
  static const String toolPhaseLint = "Validating content...";
  static const String toolPhaseCreating = "Creating document...";
  static const String toolPhaseUpdating = "Updating document...";
  static const String subagentAsyncPending =
      "Subagent accepted; results will appear in a follow-up message.";
  static const String subagentOpenChildConversation =
      "Open subagent conversation";
  static const String subagentErrorGeneric = "Subagent error";

  // NATIVE DATABASE
  static const String nativeDbRowInserted = "Row inserted";
  static const String nativeDbRowUpdated = "Row updated";
  static const String nativeDbRowDeleted = "Row deleted";
  static const String nativeDbDatabaseCreated = "Database created";
  static const String nativeDbColumnAdded = "Column added";
  static const String nativeDbBulkInsertSummary = "Bulk insert";
  static const String nativeDbDatabaseId = "Database ID";
  static const String nativeDbRows = "Rows";
  static const String nativeDbAction = "Action";
  static const String nativeDbInserted = "Inserted";
  static const String nativeDbInsertedRows = "Inserted rows";
  // Loading labels (keys must be unique across all Strings.* constants)
  static const String nativeDbLoadingList = "native_db_loading_list";
  static const String nativeDbLoadingSearch = "native_db_loading_search";
  static const String nativeDbLoadingInsert = "native_db_loading_insert";
  static const String nativeDbLoadingUpdate = "native_db_loading_update";
  static const String nativeDbLoadingDelete = "native_db_loading_delete";
  static const String nativeDbLoadingCreateDatabase =
      "native_db_loading_create_database";
  static const String nativeDbLoadingAddColumn = "native_db_loading_add_column";
  static const String exportCsv = "Export CSV";
  static const String spreadsheetLoadingInfo = "spreadsheet_loading_info";
  static const String spreadsheetLoadingSample = "spreadsheet_loading_sample";
  static const String spreadsheetLoadingSearch = "spreadsheet_loading_search";
  static const String spreadsheetLoadingInsert = "spreadsheet_loading_insert";
  static const String spreadsheetLoadingUpdate = "spreadsheet_loading_update";
  static const String spreadsheetLoadingDelete = "spreadsheet_loading_delete";
  static const String spreadsheetLoadingSummary = "spreadsheet_loading_summary";
  static const String spreadsheetLoadingDistinct = "spreadsheet_loading_distinct";
  static const String spreadsheetResultsSummary =
      'Results from "@fileName" — @rowCount rows found';
  static const String spreadsheetRowAdded = 'Row added to spreadsheet';
  static const String spreadsheetRowUpdated = 'Row updated in spreadsheet';
  static const String spreadsheetRowDeleted = 'Row deleted from spreadsheet';
  static const String spreadsheetRowDeletedWithId =
      'Row deleted from spreadsheet (id: @id)';
  static const String spreadsheetStats = 'Spreadsheet statistics';
  static const String spreadsheetStatsSummary = 'Statistics from "@fileName"';
  static const String spreadsheetTotal = 'Total';
  static const String spreadsheetAverage = 'Average';
  static const String spreadsheetMin = 'Min';
  static const String spreadsheetMax = 'Max';
  static const String spreadsheetDistinct = 'Distinct values';
  static const String spreadsheetDistinctSummary =
      'Distinct values for "@column" — @categories categories, @rows rows';
  static const String spreadsheetDistinctMore = '...and @count more values';
  static const String inspectBrowser = "Inspect Browser";
  static const String network = "Network";
  static const String dataLayer = "DataLayer";
  static const String searchNetwork = "Search network";
  static const String searchDataLayer = "Search datalayer";
  static const String requests = "Requests";
  static const String dataLayerItems = "Datalayer items";
  static const String typeYourAnswer = "Type your answer...";
  static const String suggestedChoice = "Suggested choice";
  static const String identifyToContinue = "Identify to continue";
  static const String authRequired = "You must authenticate to use this tool";
  static const String authenticate = "Authenticate";
  //MARKETPLACE
  static const String marketplace = "Marketplace";
  static const String messageLoadError =
      "Message not elaborated correctly, original content:";
  static const String model = "Model";
  static const String resolution = "Resolution";
  static const String imageDownloadFail = "Image download failed!";
  static const String imageDownloadSuccess = "Image saved in gallery!";
  static const String download = "Download";
  static const String capabilities = "Capabilities";
  static const String toolUse = "Tool Use";
  static const String cost = "Cost";
  static const String anonymousSessions = "Anonymous sessions";
  static const String attachments = "Attachments";
  static const String type = "Type";
  static const String selectAll = "Select all";
  static const String deselectAll = "Deselect all";
  static const String googleMapsApiKeyNotConfigured =
      "Google Maps API key is not configured. Please provide a Google Maps API key in PupauConfig to display maps.";
  static const String googleMapsApiKeyFailed =
      "Google Maps API key is not working. Please check your API key configuration in PupauConfig.";
  static const String checkConnectionOrRetry =
      'Check your internet connection or try again later!';
  static const String apiErrorGeneric = 'Oh no! Something went wrong!';
  static const String apiErrorSendMessage = 'Message not sent!';
  static const String cameraAccessDenied =
      "Camera access denied, please grant camera permission to the app in your device settings";
  static const String conversationForbidden =
      "Access to this conversation is denied";
  static const String conversationLoadFailed =
      "Failed to load conversation";
  static const String convertingAudio = "Waiting for transcription";
  static const String audioMessage = "Voice message";
  static const String recordAudio = "Record voice message";
  static const String sendVoiceMessage = "Send voice message";
  static const String microphoneAccessDenied =
      "Microphone access denied, please grant microphone permission to the app in your device settings";
}
