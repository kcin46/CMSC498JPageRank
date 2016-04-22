ar results = [];
$.getJSON("https://www.reddit.com/r/videos/comments/4d1gq6/cops_pull_up_400_pot_plants_in_texas_park_and/.json", function (data){
  $.each(data[1].data.children, function (i, item) {
    var comment = item.data.body
    var author = item.data.author
    var postcomment = '<p>[Author]' + author + '<br>' + comment + '</p>'
    results.push(postcomment)
  });
});