let sliderItemContainer = document.getElementById('slider-items-container');
let detailContainer = document.getElementById('detail-container');


function findGetParameter(parameterName) {
    var result = "",
        tmp = [];
    location.search
        .substr(1)
        .split("&")
        .forEach(function (item) {
            tmp = item.split("=");
            if (tmp[0] === parameterName) result = decodeURIComponent(tmp[1]);
        });
    return result;
}

if (sliderItemContainer) {
    $.ajax({
        method: 'GET',
        url: 'http://localhost:8080/movies',
        dataType: 'json',
        success: function (result) {
            for (let item of result) {
                let newSliderItem = `
            <div class="col-6 col-sm-4 col-lg-3 col-xl-2">
\t\t\t\t\t\t\t<div class="card">
\t\t\t\t\t\t\t\t<div class="card__cover">
\t\t\t\t\t\t\t\t\t<img src="${item.image}" alt="">
\t\t\t\t\t\t\t\t\t<a href="./details1.html?id=${item.id}" class="card__play">
\t\t\t\t\t\t\t\t\t\t<i class="icon ion-ios-play"></i>
\t\t\t\t\t\t\t\t\t</a>
\t\t\t\t\t\t\t\t</div>
\t\t\t\t\t\t\t\t<div class="card__content">
\t\t\t\t\t\t\t\t\t<h3 class="card__title"><a href="#">${item.title}</a></h3>
\t\t\t\t\t\t\t\t\t<span class="card__category">
\t\t\t\t\t\t\t\t\t\t<a href="#">${item.genre}</a>
\t\t\t\t\t\t\t\t\t\t<a href="#">Triler</a>
\t\t\t\t\t\t\t\t\t</span>
\t\t\t\t\t\t\t\t\t<span class="card__rate"><i class="icon ion-ios-star"></i>${item.score}</span>
\t\t\t\t\t\t\t\t</div>
\t\t\t\t\t\t\t</div>
\t\t\t\t\t\t</div>
            `
                sliderItemContainer.insertAdjacentHTML('afterbegin', newSliderItem);
            }
        }
    })
}

if (detailContainer) {
    let movieId = findGetParameter('id');
    let movieTitle = document.getElementById('movie-title');
    let movieGenre = document.getElementById('movie-genre');
    let movieImage = document.getElementById('movie-image');
    let movieScore = document.getElementById('movie-score');
    console.log(movieId);
    $.ajax({
        method: 'GET',
        url: `http://localhost:8080/movies/${movieId}`,
        dataType: 'json',
        success: function (result) {
            movieImage.setAttribute('src', result.image)
            movieTitle.innerText = result.title
            movieGenre.innerText = result.genre
            movieScore.innerText = result.score
        }
    })
}
