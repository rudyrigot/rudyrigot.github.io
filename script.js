document.addEventListener("DOMContentLoaded", function() {
    const parser = new DOMParser();

    const today = moment();
    console.log(today);

    const weeksElement = document.getElementById('weeks');
    const birthDate = weeksElement.dataset.birthDate;
    const birthDateMoment = moment(birthDate, 'YYYY-MM-DD');
    const lastDayString = weeksElement.lastElementChild.dataset.lastDay;
    let lastDayOfPreviousWeek = moment(lastDayString, 'YYYY-MM-DD');
    console.log(lastDayOfPreviousWeek);

    let firstDayOfCurrentWeek = lastDayOfPreviousWeek.clone().add(1, 'days');
    console.log(firstDayOfCurrentWeek);
    let lastDayOfCurrentWeek = lastDayOfPreviousWeek.clone().add(7, 'days');
    console.log(lastDayOfCurrentWeek);

    console.log('--------');

    while (lastDayOfCurrentWeek < today) {
        console.log(firstDayOfCurrentWeek);

        // Check if this week contains a birthday
        const isBirthdayWeek = firstDayOfCurrentWeek.format('MM-DD') <= birthDateMoment.format('MM-DD') && 
                              lastDayOfCurrentWeek.format('MM-DD') >= birthDateMoment.format('MM-DD');
        
        let weekElementAsString;
        if (isBirthdayWeek) {
            const age = firstDayOfCurrentWeek.year() - birthDateMoment.year();
            weekElementAsString = `
                <div class="week birthday" data-last-day="${lastDayOfCurrentWeek.format('YYYY-MM-DD')}">
                    <div class="shorttext">
                        🎂 Turned ${age}
                    </div>
                    <div class="longtext">
                        ${birthDateMoment.format('MMM DD YYYY')} <div class="description">Happy birthday to me!</div>
                    </div>
                </div>
            `;
        } else {
            weekElementAsString = `
                <div class="week" data-last-day="${lastDayOfCurrentWeek.format('YYYY-MM-DD')}">
                    <div class="shorttext">
                        &nbsp;
                    </div>
                    <div class="longtext">
                        From ${firstDayOfCurrentWeek.format('MMM DD YYYY')} to ${lastDayOfCurrentWeek.format('MMM DD YYYY')}
                    </div>
                </div>
            `;
        }
        const weekElement = parser.parseFromString(weekElementAsString, "text/html").body.firstChild;
        weeksElement.append(weekElement);

        // Set state for next week
        lastDayOfPreviousWeek = lastDayOfCurrentWeek
        firstDayOfCurrentWeek = lastDayOfPreviousWeek.clone().add(1, 'days');
        lastDayOfCurrentWeek = lastDayOfPreviousWeek.clone().add(7, 'days');
    }
    if (today >= firstDayOfCurrentWeek && today <= lastDayOfCurrentWeek) {
        console.log(firstDayOfCurrentWeek);

        const weekElementAsString = `
            <div class="week" data-last-day="${lastDayOfCurrentWeek.format('YYYY-MM-DD')}">
                <div class="shorttext">
                    🎯 You are here!
                </div>
                <div class="longtext">
                    ${today.format('MMM DD YYYY')} <div class="description">We have made it this far! Who knows what the future holds...</div>
                </div>
            </div>
        `;
        const weekElement = parser.parseFromString(weekElementAsString, "text/html").body.firstChild;
        weeksElement.append(weekElement);
    }
}); 