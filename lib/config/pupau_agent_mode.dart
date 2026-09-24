/// The three kinds of agent the plugin can talk to.
///
/// They differ only in which base path their endpoints live under
/// (`chat-bots` / `marketplace` / `living-agents`); everything else - the SSE
/// protocol, the rendering, the composer - is shared.
enum PupauAgentMode { assistant, marketplace, livingAgent }
