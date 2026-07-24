//! `/compact` -- compact conversation history.
//!
//! Takes an optional context argument. Stays on the existing queue pipeline:
//! returns `CommandResult::QueueCommand` so the dispatch layer enqueues it
//! as `QueueEntryKind::Command`.

use crate::slash::command::{CommandExecCtx, CommandResult, SlashCommand};

/// Compact the conversation history, optionally with a focus context.
pub struct CompactCommand;

impl SlashCommand for CompactCommand {
    fn name(&self) -> &str {
        "compact"
    }

    fn description(&self) -> &str {
        "대화 기록 압축"
    }

    fn session_scoped(&self) -> bool {
        true
    }

    fn usage(&self) -> &str {
        "/compact 압축 지시"
    }

    fn takes_args(&self) -> bool {
        true
    }

    /// Args are optional -- `/compact` with no args is valid.
    fn args_required(&self) -> bool {
        false
    }

    fn arg_placeholder(&self) -> Option<&str> {
        Some("압축 지시 (선택)")
    }

    fn run(&self, _ctx: &mut CommandExecCtx, args: &str) -> CommandResult {
        // Re-emit as queue command, preserving the full text.
        let text = if args.trim().is_empty() {
            "/compact".to_string()
        } else {
            format!("/compact {}", args)
        };
        CommandResult::QueueCommand(text)
    }
}
