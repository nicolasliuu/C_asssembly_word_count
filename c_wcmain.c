#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include "wcfuncs.h"

// Suggested number of buckets for the hash table
#define HASHTABLE_SIZE 13249

// TODO: prototypes for helper functions

int main(int argc, char **argv) {
  // stats (to be printed at end)
  uint32_t total_words = 0;
  uint32_t unique_words = 0;
  const unsigned char *best_word = (const unsigned char *) "";
  uint32_t best_word_count = 0;


  // Initialize hash table
  struct WordEntry *hashtable[HASHTABLE_SIZE];
  for (int i = 0; i < HASHTABLE_SIZE; i++) {
    hashtable[i] = malloc(sizeof(struct WordEntry));//sentinel node
  }

  // Open input file
  FILE *fp;
  if (argc > 1) {
    fp = fopen(argv[1], "r");
    if (fp == NULL) {
      fprintf(stderr, "Error: failed to open file '%s'\n", argv[1]);
      return 1;
    }
  } else {
    // Use stdin
    fp = stdin;
  }

  unsigned char curr_word[MAX_WORDLEN + 1];

  while (wc_readnext(fp, curr_word)) {
    //   increase total word count by 1
    total_words++;
  
    //   use wc_tolower to convert word to lower case
    wc_tolower(curr_word);

    //   use wc_trim_non_alpha to remove non-alphabetic characters at end of word
    wc_trim_non_alpha(curr_word);

    //   use wc_dict_find_or_insert to find or insert the word in the hash table
    struct WordEntry *word = wc_dict_find_or_insert(hashtable, HASHTABLE_SIZE, curr_word);

    // increment the WordEntry's count
  }

  // Find best word, its count, and number of unique words by traversing entire hash table
  for (int i = 0; i < HASHTABLE_SIZE; i++) {
    struct WordEntry *cursor = hashtable[i];
    while (cursor->next != NULL) {
      unique_words++;
      // printf("%s %d\n", cursor->word, cursor->count);
      if (cursor->next->count > best_word_count) {
        best_word = cursor->next->word;
        best_word_count = cursor->next->count;
      }
      cursor = cursor->next;
    }
  }

  printf("Total words read: %u\n", (unsigned int) total_words);
  printf("Unique words read: %u\n", (unsigned int) unique_words);
  printf("Most frequent word: %s (%u)\n", (const char *) best_word, best_word_count);

  // TODO: make sure file is closed (if one was opened)
  fclose(fp);
  // TODO: make sure memory is freed
  for (int i = 0; i < HASHTABLE_SIZE; i++) {
    struct WordEntry *cursor = hashtable[i];
    wc_free_chain(cursor);
  }

  return 0;
}

// TODO: definitions of helper functions
