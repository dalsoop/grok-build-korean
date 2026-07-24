//! grok-build's session-level summarization prompt.
//!
//! Split out of the crate-root `prompt` module so grok-build's full-replace
//! prompt lives alongside the rest of its [`code_compaction`](crate::code_compaction)
//! subsystem. The Grok chat's step-level intra prompt
//! ([`format_compaction_prompt`](crate::prompt::format_compaction_prompt))
//! stays at the crate root.

/// Build grok-build's session-level summarization prompt (no chat history).
///
/// `user_context` is the optional `/compact <text>` user-provided context,
/// spliced inline into the structured prompt. Ported verbatim from
/// `xai-grok-shell::session::helpers::session_compact::build_compaction_prompt`
/// (the `use_short_prompt == false` branch).
pub fn build_summary_prompt(user_context: Option<&str>) -> String {
    let user_context_section = match user_context {
        Some(context) => format!(
            "\n\n**이 압축에 대한 사용자 제공 컨텍스트:**\n{}\n\n이 컨텍스트를 요약에 반영하고, 관련 섹션에서 분명히 다루세요.\n\n",
            context
        ),
        None => String::new(),
    };

    include_str!("templates/full_replace_summary_prompt.txt")
        .replace("{user_context_section}", &user_context_section)
}

/// The short "self-summarization" prompt variant
/// (mirrors `xai-grok-shell`'s `SELF_SUMMARIZATION_PROMPT`). Framed
/// as "summarize for a successor assistant that only sees the user's original
/// query plus this summary." Kept here so every harness (the shell and the
/// harness crate) shares one definition instead of each carrying a
/// private copy.
pub const SELF_SUMMARIZATION_PROMPT: &str = r#"<summary_request>
지금까지의 대화를 한국어로 요약하세요. 이 요약(thinking 이후 전부)은 후속 AI 어시스턴트가
작업을 이어가기 위해 사용합니다. 후속 어시스턴트는 사용자의 원래 질의와 이 요약만 보며,
이 대화의 도구 호출·도구 출력에는 접근할 수 없습니다. 요약 목적은 이어 작업에 필요한
핵심 정보를 보존하면서 컨텍스트를 압축하는 것입니다. 포함할 내용: 사용자 요청, 지금까지
한 일, 관련 파일 경로·코드 세부사항, 만난 오류와 해결 방법, 남은 일. 코드·경로·CLI·
고유명사는 원문 유지. 응답에서 도구를 호출하지 마세요.
</summary_request>"#;

/// Which summarization prompt a full-replace pass should send.
///
/// The prompt is owned by the harness's [`CompactionSampler`] impl (it appends
/// the prompt as the final user message before sampling), not by the shared
/// orchestrator. This enum lets each harness select the right one in one place
/// so the structured (grok-build) and short self-summary prompts stay
/// shared instead of duplicated per harness.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum SummaryPromptKind {
    /// grok-build's detailed, numbered-section summary prompt.
    #[default]
    Structured,
    /// The short self-summarization prompt.
    SelfSummary,
}

/// Build the full-replace summarization prompt for the given [`SummaryPromptKind`].
///
/// `user_context` is the optional `/compact <text>` user-provided context.
/// For [`SummaryPromptKind::Structured`] it is spliced inline (see
/// [`build_summary_prompt`]); for [`SummaryPromptKind::SelfSummary`] it is
/// appended as a sibling `<user_provided_context>` block, matching the shell's
/// `build_compaction_prompt(use_short_prompt = true)` behavior.
pub fn build_summary_prompt_kind(kind: SummaryPromptKind, user_context: Option<&str>) -> String {
    match kind {
        SummaryPromptKind::Structured => build_summary_prompt(user_context),
        SummaryPromptKind::SelfSummary => match user_context {
            Some(ctx) => format!(
                "{SELF_SUMMARIZATION_PROMPT}\n\n\
                 <user_provided_context>\n{ctx}\n</user_provided_context>\n\n\
                 위 사용자 제공 컨텍스트를 요약에 반영하세요."
            ),
            None => SELF_SUMMARIZATION_PROMPT.to_string(),
        },
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn summary_prompt_splices_context_section_inline() {
        let p = build_summary_prompt(Some("focus on auth"));
        assert!(p.contains("**이 압축에 대한 사용자 제공 컨텍스트:**\nfocus on auth"));
        assert!(p.contains("1. Primary Request and Intent"));
        assert!(p.contains("9. Optional Next Step"));
        assert!(p.contains("Write the entire summary body in Korean"));
    }

    #[test]
    fn summary_prompt_without_context_has_no_context_header() {
        let p = build_summary_prompt(None);
        assert!(!p.contains("**이 압축에 대한 사용자 제공 컨텍스트:**"));
        assert!(p.contains("6. All User Messages"));
        // Current prompt: no separate analysis block, concise framing.
        assert!(p.contains("do NOT emit a separate analysis block"));
        assert!(p.contains("faithful, concise summary"));
        assert!(p.contains("Write the entire summary body in Korean"));
    }

    #[test]
    fn kind_structured_matches_build_summary_prompt() {
        // The Structured kind must be byte-identical to the legacy entry point
        // so routing through the selector never changes grok-build's prompt.
        assert_eq!(
            build_summary_prompt_kind(SummaryPromptKind::Structured, None),
            build_summary_prompt(None)
        );
        assert_eq!(
            build_summary_prompt_kind(SummaryPromptKind::Structured, Some("focus on auth")),
            build_summary_prompt(Some("focus on auth"))
        );
    }

    #[test]
    fn kind_self_summary_without_context_is_bare_prompt() {
        let p = build_summary_prompt_kind(SummaryPromptKind::SelfSummary, None);
        assert_eq!(p, SELF_SUMMARIZATION_PROMPT);
        assert!(p.contains("<summary_request>"));
        // Must NOT carry the structured prompt's numbered sections.
        assert!(!p.contains("1. Primary Request and Intent"));
    }

    #[test]
    fn kind_self_summary_with_context_appends_sibling_block() {
        let p = build_summary_prompt_kind(SummaryPromptKind::SelfSummary, Some("focus on auth"));
        assert!(p.starts_with(SELF_SUMMARIZATION_PROMPT));
        assert!(p.contains("<user_provided_context>\nfocus on auth\n</user_provided_context>"));
        assert!(p.contains("위 사용자 제공 컨텍스트를 요약에 반영하세요"));
    }

    #[test]
    fn default_kind_is_structured() {
        assert_eq!(SummaryPromptKind::default(), SummaryPromptKind::Structured);
    }
}
