Run scope-safe recon for the target named "$ARGUMENTS".

Steps:
1. Confirm `targets/$ARGUMENTS/scope.yaml` exists and read it back to me. If the
   scope is empty or a placeholder, STOP and ask me to fill it in first.
2. Run `bash scripts/recon.sh $ARGUMENTS`.
3. Run `bash scripts/js-analysis.sh $ARGUMENTS`.
4. Summarize what landed in `targets/$ARGUMENTS/recon/`: how many live hosts,
   interesting titles/tech from httpx.jsonl, notable nuclei hits, and any JS
   endpoints or secret candidates worth a look.
Do NOT test anything yet — just recon + summary.
