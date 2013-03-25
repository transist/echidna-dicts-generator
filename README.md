# Usage

## bin/spider.rb
  1. Scrape douban group discussions, store data into database named corpus and collection named contents in your MongoDB.
  2. Single thread.

## bin/process.rb
  * Process contents in corpus.
    * Segmenting
    * Stopwording
    * Assemble continous remain characters.
    * Counting TF-IDF for scoring frequences.
  * -h --help
    * Shows usage.
  * -a --analysis
    * Anaylysis processed terms, rank and unify them.
  * -s --save
    * Save analyzed terms into to file.
  