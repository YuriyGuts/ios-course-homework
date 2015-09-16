import Foundation

class DiaryEntry {
    let date: NSDate
    var title: String?
    var body: String?
    var tags: [String]
    
    init(date: NSDate, title: String?=nil, body: String?=nil, tags: [String]=[]) {
        self.date = date
        self.title = title
        self.body = body
        self.tags = tags
    }
    
    private var formattedDateLine: String {
        let titleDateFormatter = NSDateFormatter()
        titleDateFormatter.dateFormat = "dd MMMM yyyy"
        return titleDateFormatter.stringFromDate(date)
    }
    
    private var formattedTitleLine: String {
        return title ?? ""
    }
    
    private var formattedTagLine: String {
        return tags.map({ "[\($0)]" }).joinWithSeparator(" ")
    }
    
    private var formattedBody: String {
        return body ?? ""
    }
    
    func fullDescription() -> String {
        let elements = [
            formattedDateLine,
            formattedTitleLine,
            formattedTagLine,
            formattedBody,
        ]
        return elements.filter({ !$0.isEmpty }).joinWithSeparator("\n")
    }
}

let blankEntry = DiaryEntry(date: NSDate())
blankEntry.fullDescription()

let entryWithAllFields = DiaryEntry(date: NSDate(),
    title: "Такой день #1",
    body: "Сегодня утром я покушал жареную картошку и пошёл на работу. С Романом собрали мусор с урн, подмели. Потом Романа забрал плотник - помогать. Меня никто не забрал, я так сидел. Это увидел замдиректора и заставил меня пройтись по территории. Я увидел в одном месте строительный мусор под окнами, убрал его, насыпал в тачку. Потом меня забрал Александр - помогать ему снимать решётки с окон. Потом меня забрал плотник, мы с ним перенесли снятые решётки на склад. Потом я так сидел, ждал окончания рабочего дня. Дождался и пошёл домой. Вечером я пошёл в кафе, кушал свинячий шашлык и пил чай. Алкоголь не пил, я трезвенник. Пошёл домой. Буду отдыхать. Начал дочитывать роман Радзинского \"Распутин\", интересно. Такой день.",
    tags: ["такой", "день"]
)
entryWithAllFields.fullDescription()

let entryWithSomeFields = DiaryEntry(date: NSDate(),
    body: "Сегодня утром я покушал шашлык с картошкой и пошёл на работу. С Романом собрали мусор с урн, подмели, потом так сидели. Потом меня забрал с собой замдиректора (Роман ушёл пополнять счёт на телефоне), поехали в строительный магазин, покупали пластиковые панели. В трёх магазинах покупали. Мне помогал водитель грузить их на тележку и возить. Весь обед проездили, я освободился только к концу обеда. Покушал на обед борщ, хлеб был. После обеда так сидели. От нечего делать Роман срубил одно небольшое дерево, оно навалилось на забор. Вечером пошли по домам. Я докушал шашлык с картошкой и кушал торт с чаем, торт от дня рождения остался, мне мама отдала. Буду отдыхать. Такой день.",
    tags: []
)
entryWithSomeFields.fullDescription()
