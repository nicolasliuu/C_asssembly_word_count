#include <stdio.h>
#include <stdint.h>
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

  // TODO: implement

  // Initialize hash table
  struct WordEntry *hashtable[HASHTABLE_SIZE];

  // Open input file
  FILE *fp = fopen(argv[1], "r");
  if (fp == NULL) {
    fprintf(stderr, "Error: failed to open file '%s'\n", argv[1]);
    return 1;
  }

  //   while ( next word is read successfully using wc_readnext ) {
  //   increase total word count by 1

  //   use wc_tolower to convert word to lower case

  //   use wc_trim_non_alpha to remove non-alphabetic characters at end of word

  //   use wc_dict_find_or_insert to find or insert the word in the hash table

  //   increment the WordEntry's count
  // }

  printf("Total words read: %u\n", (unsigned int) total_words);
  printf("Unique words read: %u\n", (unsigned int) unique_words);
  printf("Most frequent word: %s (%u)\n", (const char *) best_word, best_word_count);

  // TODO: make sure file is closed (if one was opened)
  // TODO: make sure memory is freed

  return 0;
}

// TODO: definitions of helper functions
