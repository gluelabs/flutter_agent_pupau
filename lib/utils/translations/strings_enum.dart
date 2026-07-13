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
  static const String list = 'List';
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
  static const String memoriesUsed = 'Memories used';
  static const String memoriesAlwaysActive = 'Always active';
  static const String memoriesRelevantForThisResponse =
      'Relevant for this response';
  static const String memorySourceUser = 'User';
  static const String memorySourceSystem = 'System';
  static const String always = 'Always';
  static const String memorySaved = 'Memory saved';
  static const String memoryUpdated = 'Memory updated';
  static const String memoryRemoved = 'Memory removed';
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
  static const String skillEventLoaded = "Skill loaded";
  static const String skillEventUnloaded = "Skill unloaded";
  /// Use @count placeholder for the number of skills.
  static const String skillsActiveCount = "@count active skills";
  static const String activeSkills = "Active Skills";
  static const String activeSkillsInfo =
      "Skills currently loaded in this conversation for the agent.";
  static const String agent = "Agent";
  static const String skillLoadedBy = "Loaded by";
  static const String newConversationTitle = "New conversation title";
  static const String newConversationCreated = "New conversation created!";
  static const String conversationStoppedCorrectly =
      "Conversation stopped correctly!";
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
  static const String scrollToBottom = "Scroll to bottom";
  static const String scrollToTop = "Scroll to top";
  static const String autoScrollMagnetOnTapToTurnOff =
      "Auto-scroll magnet is ON. Tap to turn OFF.";
  static const String autoScrollMagnetOffTapToTurnOn =
      "Auto-scroll magnet is OFF. Tap to turn ON.";
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
  static const String nativeDbScopePrivate = "Private";
  static const String nativeDbScopeCompany = "Company";
  static const String nativeDbScopeConversation = "Conversation";
  // Loading labels (keys must be unique across all Strings.* constants)
  static const String nativeDbLoadingList = "Loading databases...";
  static const String nativeDbLoadingSearch = "Searching...";
  static const String nativeDbLoadingInsert = "Inserting row...";
  static const String nativeDbLoadingUpdate = "Updating row...";
  static const String nativeDbLoadingDelete = "Deleting row...";
  static const String nativeDbLoadingCreateDatabase =
      "Creating database...";
  static const String nativeDbLoadingAddColumn = "Adding column...";

  // ATTACHMENT (JIT) TOOLS
  static const String attachmentToolLoadingList = "Listing attachments...";
  static const String attachmentToolLoadingOutline =
      "Reading attachment structure...";
  static const String attachmentToolLoadingRead = "Reading attachment...";
  static const String attachmentToolLoadingGrep = "Searching attachment...";
  static const String attachmentToolLoadingSearch =
      "Searching attachments...";
  static const String attachmentToolReadLabel = 'Reading "@fileName"';
  static const String attachmentToolReadRangeLabel =
      'Reading "@fileName" (lines @fromLine-@toLine)';
  static const String attachmentToolGrepLabel =
      'Searching for "@pattern" in @fileName';
  static const String attachmentToolGrepAllLabel =
      'Searching for "@pattern" in attachments';
  static const String attachmentToolSearchLabel =
      'Searching attachments for "@searchText"';
  static const String attachmentToolOutlineLabel =
      'Reading structure of "@fileName"';
  static const String attachmentToolTruncatedNote = "Result truncated";
  static const String attachmentToolSoftNoteTitle = "Note";

  // RAG GROUNDING CITATIONS
  // Note: panel title and attachment-origin label reuse the existing
  // `sources`/`attachment` keys above instead of duplicating their value.
  static const String citationOriginKnowledgeBase = "Knowledge base";
  static const String citationOriginWebSearch = "Web search";
  static const String citationOpenAttachment = "Open attachment";
  static const String citationPreviewUnavailable = "Preview unavailable";
  static const String citationVerificationPending = "Verifying…";
  static const String citationVerificationGrounded = "grounded";
  static const String exportCsv = "Export CSV";
  static const String spreadsheetLoadingInfo = "Reading spreadsheet structure...";
  static const String spreadsheetLoadingSample = "Loading sample rows...";
  static const String spreadsheetLoadingSearch = "Searching spreadsheet...";
  static const String spreadsheetLoadingInsert = "Adding row to spreadsheet...";
  static const String spreadsheetLoadingSummary = "Calculating statistics...";
  static const String spreadsheetLoadingDistinct = "Analyzing distinct values...";
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
  static const String promptSuggestionsForYou = "Prompt suggestions for you";
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
  static const String voiceModeTooltip = "Voice mode";
  static const String voiceIdle = "Say something…";
  static const String voiceListening = "Listening…";
  static const String voiceThinking = "Thinking…";
  static const String voiceSpeaking = "Speaking…";
  static const String microphoneAccessDenied =
      "Microphone access denied, please grant microphone permission to the app in your device settings";
  static const String noItemsFound = "No items found...";

  // THINKING SETTINGS
  static const String thinkingNotSupported = "This model does not support thinking.";
  static const String enableThinking = "Enable thinking";
  static const String effort = "Effort";
  static const String notSelected = "Not selected";

  // DASHBOARD
  static const String chatDashboard = "Chat Dashboard";
  static const String generating1 = "Accomplishing";
  static const String generating2 = "Actioning";
  static const String generating3 = "Actualizing";
  static const String generating4 = "Architecting";
  static const String generating5 = "Baking";
  static const String generating6 = "Beaming";
  static const String generating7 = "Beboppin'";
  static const String generating8 = "Befuddling";
  static const String generating9 = "Billowing";
  static const String generating10 = "Blanching";
  static const String generating11 = "Bloviating";
  static const String generating12 = "Boogieing";
  static const String generating13 = "Boondoggling";
  static const String generating14 = "Booping";
  static const String generating15 = "Bootstrapping";
  static const String generating16 = "Brewing";
  static const String generating17 = "Bunning";
  static const String generating18 = "Burrowing";
  static const String generating19 = "Calculating";
  static const String generating20 = "Canoodling";
  static const String generating21 = "Caramelizing";
  static const String generating22 = "Cascading";
  static const String generating23 = "Catapulting";
  static const String generating24 = "Cerebrating";
  static const String generating25 = "Channeling";
  static const String generating26 = "Channelling";
  static const String generating27 = "Choreographing";
  static const String generating28 = "Churning";
  static const String generating29 = "Coalescing";
  static const String generating30 = "Cogitating";
  static const String generating31 = "Combobulating";
  static const String generating32 = "Composing";
  static const String generating33 = "Computing";
  static const String generating34 = "Concocting";
  static const String generating35 = "Considering";
  static const String generating36 = "Contemplating";
  static const String generating37 = "Cooking";
  static const String generating38 = "Crafting";
  static const String generating39 = "Creating";
  static const String generating40 = "Crunching";
  static const String generating41 = "Crystallizing";
  static const String generating42 = "Cultivating";
  static const String generating43 = "Deciphering";
  static const String generating44 = "Deliberating";
  static const String generating45 = "Determining";
  static const String generating46 = "Dilly-dallying";
  static const String generating47 = "Discombobulating";
  static const String generating48 = "Doing";
  static const String generating49 = "Doodling";
  static const String generating50 = "Drizzling";
  static const String generating51 = "Ebbing";
  static const String generating52 = "Effecting";
  static const String generating53 = "Elucidating";
  static const String generating54 = "Embellishing";
  static const String generating55 = "Enchanting";
  static const String generating56 = "Envisioning";
  static const String generating57 = "Evaporating";
  static const String generating58 = "Fermenting";
  static const String generating59 = "Fiddle-faddling";
  static const String generating60 = "Finagling";
  static const String generating61 = "Flambéing";
  static const String generating62 = "Flibbertigibbeting";
  static const String generating63 = "Flowing";
  static const String generating64 = "Flummoxing";
  static const String generating65 = "Fluttering";
  static const String generating66 = "Forging";
  static const String generating67 = "Forming";
  static const String generating68 = "Frolicking";
  static const String generating69 = "Frosting";
  static const String generating70 = "Gallivanting";
  static const String generating71 = "Galloping";
  static const String generating72 = "Garnishing";
  static const String generating73 = "Generating";
  static const String generating74 = "Gesticulating";
  static const String generating75 = "Germinating";
  static const String generating76 = "Gitifying";
  static const String generating77 = "Grooving";
  static const String generating78 = "Gusting";
  static const String generating79 = "Harmonizing";
  static const String generating80 = "Hashing";
  static const String generating81 = "Hatching";
  static const String generating82 = "Herding";
  static const String generating83 = "Honking";
  static const String generating84 = "Hullaballooing";
  static const String generating85 = "Hyperspacing";
  static const String generating86 = "Ideating";
  static const String generating87 = "Imagining";
  static const String generating88 = "Improvising";
  static const String generating89 = "Incubating";
  static const String generating90 = "Inferring";
  static const String generating91 = "Infusing";
  static const String generating92 = "Ionizing";
  static const String generating93 = "Jitterbugging";
  static const String generating94 = "Julienning";
  static const String generating95 = "Kneading";
  static const String generating96 = "Leavening";
  static const String generating97 = "Levitating";
  static const String generating98 = "Lollygagging";
  static const String generating99 = "Manifesting";
  static const String generating100 = "Marinating";
  static const String generating101 = "Meandering";
  static const String generating102 = "Metamorphosing";
  static const String generating103 = "Misting";
  static const String generating104 = "Moonwalking";
  static const String generating105 = "Moseying";
  static const String generating106 = "Mulling";
  static const String generating107 = "Mustering";
  static const String generating108 = "Musing";
  static const String generating109 = "Nebulizing";
  static const String generating110 = "Nesting";
  static const String generating111 = "Newspapering";
  static const String generating112 = "Noodling";
  static const String generating113 = "Nucleating";
  static const String generating114 = "Orbiting";
  static const String generating115 = "Orchestrating";
  static const String generating116 = "Osmosing";
  static const String generating117 = "Perambulating";
  static const String generating118 = "Percolating";
  static const String generating119 = "Perusing";
  static const String generating120 = "Philosophising";
  static const String generating121 = "Photosynthesizing";
  static const String generating122 = "Pollinating";
  static const String generating123 = "Pondering";
  static const String generating124 = "Pontificating";
  static const String generating125 = "Pouncing";
  static const String generating126 = "Precipitating";
  static const String generating127 = "Prestidigitating";
  static const String generating128 = "Processing";
  static const String generating129 = "Proofing";
  static const String generating130 = "Propagating";
  static const String generating131 = "Puttering";
  static const String generating132 = "Puzzling";
  static const String generating133 = "Quantumizing";
  static const String generating134 = "Razzle-dazzling";
  static const String generating135 = "Razzmatazzing";
  static const String generating136 = "Recombobulating";
  static const String generating137 = "Reticulating";
  static const String generating138 = "Roosting";
  static const String generating139 = "Ruminating";
  static const String generating140 = "Sautéing";
  static const String generating141 = "Scampering";
  static const String generating142 = "Schlepping";
  static const String generating143 = "Scurrying";
  static const String generating144 = "Seasoning";
  static const String generating145 = "Shenaniganing";
  static const String generating146 = "Shimmying";
  static const String generating147 = "Simmering";
  static const String generating148 = "Skedaddling";
  static const String generating149 = "Sketching";
  static const String generating150 = "Slithering";
  static const String generating151 = "Smooshing";
  static const String generating152 = "Sock-hopping";
  static const String generating153 = "Spelunking";
  static const String generating154 = "Spinning";
  static const String generating155 = "Sprouting";
  static const String generating156 = "Stewing";
  static const String generating157 = "Sublimating";
  static const String generating158 = "Swirling";
  static const String generating159 = "Swooping";
  static const String generating160 = "Symbioting";
  static const String generating161 = "Synthesizing";
  static const String generating162 = "Tempering";
  static const String generating163 = "Thinking";
  static const String generating164 = "Thundering";
  static const String generating165 = "Tinkering";
  static const String generating166 = "Tomfoolering";
  static const String generating167 = "Topsy-turvying";
  static const String generating168 = "Transfiguring";
  static const String generating169 = "Transmuting";
  static const String generating170 = "Twisting";
  static const String generating171 = "Undulating";
  static const String generating172 = "Unfurling";
  static const String generating173 = "Unravelling";
  static const String generating174 = "Vibing";
  static const String generating175 = "Waddling";
  static const String generating176 = "Wandering";
  static const String generating177 = "Warping";
  static const String generating178 = "Whatchamacalliting";
  static const String generating179 = "Whirlpooling";
  static const String generating180 = "Whirring";
  static const String generating181 = "Whisking";
  static const String generating182 = "Wibbling";
  static const String generating183 = "Working";
  static const String generating184 = "Wrangling";
  static const String generating185 = "Zesting";
  static const String generating186 = "Zigzagging";

  static const List<String> generatingPhrases = <String>[
    generating1,
    generating2,
    generating3,
    generating4,
    generating5,
    generating6,
    generating7,
    generating8,
    generating9,
    generating10,
    generating11,
    generating12,
    generating13,
    generating14,
    generating15,
    generating16,
    generating17,
    generating18,
    generating19,
    generating20,
    generating21,
    generating22,
    generating23,
    generating24,
    generating25,
    generating26,
    generating27,
    generating28,
    generating29,
    generating30,
    generating31,
    generating32,
    generating33,
    generating34,
    generating35,
    generating36,
    generating37,
    generating38,
    generating39,
    generating40,
    generating41,
    generating42,
    generating43,
    generating44,
    generating45,
    generating46,
    generating47,
    generating48,
    generating49,
    generating50,
    generating51,
    generating52,
    generating53,
    generating54,
    generating55,
    generating56,
    generating57,
    generating58,
    generating59,
    generating60,
    generating61,
    generating62,
    generating63,
    generating64,
    generating65,
    generating66,
    generating67,
    generating68,
    generating69,
    generating70,
    generating71,
    generating72,
    generating73,
    generating74,
    generating75,
    generating76,
    generating77,
    generating78,
    generating79,
    generating80,
    generating81,
    generating82,
    generating83,
    generating84,
    generating85,
    generating86,
    generating87,
    generating88,
    generating89,
    generating90,
    generating91,
    generating92,
    generating93,
    generating94,
    generating95,
    generating96,
    generating97,
    generating98,
    generating99,
    generating100,
    generating101,
    generating102,
    generating103,
    generating104,
    generating105,
    generating106,
    generating107,
    generating108,
    generating109,
    generating110,
    generating111,
    generating112,
    generating113,
    generating114,
    generating115,
    generating116,
    generating117,
    generating118,
    generating119,
    generating120,
    generating121,
    generating122,
    generating123,
    generating124,
    generating125,
    generating126,
    generating127,
    generating128,
    generating129,
    generating130,
    generating131,
    generating132,
    generating133,
    generating134,
    generating135,
    generating136,
    generating137,
    generating138,
    generating139,
    generating140,
    generating141,
    generating142,
    generating143,
    generating144,
    generating145,
    generating146,
    generating147,
    generating148,
    generating149,
    generating150,
    generating151,
    generating152,
    generating153,
    generating154,
    generating155,
    generating156,
    generating157,
    generating158,
    generating159,
    generating160,
    generating161,
    generating162,
    generating163,
    generating164,
    generating165,
    generating166,
    generating167,
    generating168,
    generating169,
    generating170,
    generating171,
    generating172,
    generating173,
    generating174,
    generating175,
    generating176,
    generating177,
    generating178,
    generating179,
    generating180,
    generating181,
    generating182,
    generating183,
    generating184,
    generating185,
    generating186,
  ];

}
