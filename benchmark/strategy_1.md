# Strategy 1

## Process
1. Segmentation with default dictionaries.
2. Pick out stopwords with stopwords list in echidna-dicts-data.
3. Assemble continuous characters to terms.
4. Calculate TF/IDF for each term.
5. Filtering useless words, to generate an extra dictionary, for segementation loading.

## Result and Analysis
1. After parsing 1k posts in douban, 30k terms were assembled, 22k terms can be filtered out by machine, roughly guessing, 800 ~ 1500 terms were useful(meaningful).
2. Larger corpus generates better terms, and takes longer to calculate IDF of terms.
3. Improve stopwords pickup strategies.
4. Improve algorithm to score if a term is useful term.