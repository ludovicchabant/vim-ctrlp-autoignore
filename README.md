
# CtrlP Auto-Ignore

This CtrlP extension adds support for per-project ignore patterns, as defined by
a `.ctrlpignore` file located at the root of the the project. It's like
`.gitignore` or `.hgignore` for CtrlP.

Install it by using you preferred Vim plugin manager (Pathogen or Vundle are
recommended), and adding this to your `vimrc`:

    let g:ctrlp_extensions = ['autoignore']

Of course, add `'autoignore'` to an existing `g:ctrlp_extensions` if
you're already using some other CtrlP extensions.

Next, add a `.ctrlpignore` file at the root of one of your project, and specify
file and directory patterns to ignore. Don't forget to hit `<F5>` next time you
open CtrlP to force it to refresh its search results.

Use `:help ctrlp-autoignore` for more information.

