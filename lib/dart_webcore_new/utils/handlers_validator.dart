bool checkPathTemplate(String pathTemplate) {
  bool valid = true;
  // path template can have keys like <user_id> and *<file_path>
  // normal key can <user_id> equal just one / value like 4587445
  // complex keys can *<file_path> must be at the end of the path template
  // one path template can only have one complex path template at the end

  return valid;
}
