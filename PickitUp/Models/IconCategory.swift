//
//  IconCategory.swift
//  PickitUp
//
//  Created by Erfan Yarahmadi on 24/02/26.
//


import Foundation

// MARK: - IconCategory

struct IconCategory: Identifiable {
    let id = UUID()
    let name: String
    let symbols: [IconSymbol]
}

struct IconSymbol: Identifiable, Hashable {
    let id = UUID()
    let name: String        // display name
    let symbol: String      // SF Symbol name
}

// MARK: - IconLibrary

enum IconLibrary {

    static let all: [IconCategory] = [
        everyday,
        travel,
        fitness,
        food,
        tech,
        clothing,
        health,
        work,
        education,
        home,
        finance,
        nature,
        sports,
        music,
        people,
        safety,
        misc,
    ]

    // Flat list for search
    static var flat: [IconSymbol] {
        all.flatMap(\.symbols)
    }

    // MARK: Categories

    static let everyday = IconCategory(name: "Everyday", symbols: [
        IconSymbol(name: "Keys",         symbol: "key.fill"),
        IconSymbol(name: "Wallet",        symbol: "wallet.pass.fill"),
        IconSymbol(name: "Bag",           symbol: "bag.fill"),
        IconSymbol(name: "Backpack",      symbol: "backpack.fill"),
        IconSymbol(name: "Umbrella",      symbol: "umbrella.fill"),
        IconSymbol(name: "Sunglasses",    symbol: "sunglasses.fill"),
        IconSymbol(name: "Watch",         symbol: "applewatch"),
        IconSymbol(name: "Phone",         symbol: "iphone"),
        IconSymbol(name: "Headphones",    symbol: "headphones"),
        IconSymbol(name: "AirPods",       symbol: "airpodspro"),
        IconSymbol(name: "Charger",       symbol: "bolt.fill"),
        IconSymbol(name: "Water Bottle",  symbol: "waterbottle.fill"),
        IconSymbol(name: "Coffee",        symbol: "cup.and.saucer.fill"),
        IconSymbol(name: "Notebook",      symbol: "book.fill"),
        IconSymbol(name: "Pen",           symbol: "pencil"),
        IconSymbol(name: "Folder",        symbol: "folder.fill"),
        IconSymbol(name: "ID Card",       symbol: "creditcard.fill"),
        IconSymbol(name: "Mask",          symbol: "mouth.fill"),
        IconSymbol(name: "Hand Sanitizer",symbol: "hands.sparkles.fill"),
        IconSymbol(name: "Lock",          symbol: "lock.fill"),
    ])

    static let travel = IconCategory(name: "Travel", symbols: [
        IconSymbol(name: "Airplane",      symbol: "airplane"),
        IconSymbol(name: "Car",           symbol: "car.fill"),
        IconSymbol(name: "Train",         symbol: "tram.fill"),
        IconSymbol(name: "Bus",           symbol: "bus.fill"),
        IconSymbol(name: "Bicycle",       symbol: "bicycle"),
        IconSymbol(name: "Scooter",       symbol: "scooter"),
        IconSymbol(name: "Passport",      symbol: "doc.text.fill"),
        IconSymbol(name: "Luggage",       symbol: "suitcase.fill"),
        IconSymbol(name: "Map",           symbol: "map.fill"),
        IconSymbol(name: "Location Pin",  symbol: "mappin.circle.fill"),
        IconSymbol(name: "Compass",       symbol: "safari.fill"),
        IconSymbol(name: "Camera",        symbol: "camera.fill"),
        IconSymbol(name: "Tent",          symbol: "tent.fill"),
        IconSymbol(name: "Ferry",         symbol: "ferry.fill"),
        IconSymbol(name: "Fuel",          symbol: "fuelpump.fill"),
        IconSymbol(name: "Parking",       symbol: "parkingsign.circle.fill"),
        IconSymbol(name: "Ticket",        symbol: "ticket.fill"),
        IconSymbol(name: "Hotel",         symbol: "building.2.fill"),
    ])

    static let fitness = IconCategory(name: "Fitness", symbols: [
        IconSymbol(name: "Gym",           symbol: "figure.strengthtraining.traditional"),
        IconSymbol(name: "Running",       symbol: "figure.run"),
        IconSymbol(name: "Cycling",       symbol: "figure.outdoor.cycle"),
        IconSymbol(name: "Swimming",      symbol: "figure.pool.swim"),
        IconSymbol(name: "Yoga",          symbol: "figure.mind.and.body"),
        IconSymbol(name: "Hiking",        symbol: "figure.hiking"),
        IconSymbol(name: "Basketball",    symbol: "basketball.fill"),
        IconSymbol(name: "Soccer",        symbol: "soccerball"),
        IconSymbol(name: "Tennis",        symbol: "tennisball.fill"),
        IconSymbol(name: "Dumbbell",      symbol: "dumbbell.fill"),
        IconSymbol(name: "Heart Rate",    symbol: "heart.fill"),
        IconSymbol(name: "Trophy",        symbol: "trophy.fill"),
        IconSymbol(name: "Medal",         symbol: "medal.fill"),
        IconSymbol(name: "Timer",         symbol: "stopwatch.fill"),
        IconSymbol(name: "Towel",         symbol: "towel.fill"),
        IconSymbol(name: "Shower",        symbol: "shower.fill"),
        IconSymbol(name: "Sneakers",      symbol: "shoeprints.fill"),
        IconSymbol(name: "Sports Bag",    symbol: "bag.fill"),
    ])

    static let food = IconCategory(name: "Food & Drink", symbols: [
        IconSymbol(name: "Fork & Knife",  symbol: "fork.knife"),
        IconSymbol(name: "Pizza",         symbol: "allergens"),
        IconSymbol(name: "Apple",         symbol: "apple.logo"),
        IconSymbol(name: "Coffee Cup",    symbol: "cup.and.saucer.fill"),
        IconSymbol(name: "Takeout Bag",   symbol: "bag.fill"),
        IconSymbol(name: "Wine Glass",    symbol: "wineglass.fill"),
        IconSymbol(name: "Mug",          symbol: "mug.fill"),
        IconSymbol(name: "Carrot",        symbol: "carrot.fill"),
        IconSymbol(name: "Flame (Hot)",   symbol: "flame.fill"),
        IconSymbol(name: "Lunchbox",      symbol: "lunchbox.fill"),
        IconSymbol(name: "Shopping Cart", symbol: "cart.fill"),
        IconSymbol(name: "Refrigerator",  symbol: "refrigerator.fill"),
    ])

    static let tech = IconCategory(name: "Tech & Devices", symbols: [
        IconSymbol(name: "iPhone",        symbol: "iphone"),
        IconSymbol(name: "iPad",          symbol: "ipad"),
        IconSymbol(name: "MacBook",       symbol: "laptopcomputer"),
        IconSymbol(name: "Apple Watch",   symbol: "applewatch"),
        IconSymbol(name: "AirPods Pro",   symbol: "airpodspro"),
        IconSymbol(name: "Headphones",    symbol: "headphones"),
        IconSymbol(name: "Speaker",       symbol: "hifispeaker.fill"),
        IconSymbol(name: "Keyboard",      symbol: "keyboard.fill"),
        IconSymbol(name: "Mouse",         symbol: "computermouse.fill"),
        IconSymbol(name: "TV",            symbol: "tv.fill"),
        IconSymbol(name: "Game Controller",symbol: "gamecontroller.fill"),
        IconSymbol(name: "USB Cable",     symbol: "cable.connector"),
        IconSymbol(name: "Battery",       symbol: "battery.100percent"),
        IconSymbol(name: "WiFi",          symbol: "wifi"),
        IconSymbol(name: "Bluetooth",     symbol: "bluetooth"),
        IconSymbol(name: "Hard Drive",    symbol: "externaldrive.fill"),
        IconSymbol(name: "Cloud",         symbol: "icloud.fill"),
        IconSymbol(name: "Printer",       symbol: "printer.fill"),
    ])

    static let clothing = IconCategory(name: "Clothing", symbols: [
        IconSymbol(name: "T-Shirt",       symbol: "tshirt.fill"),
        IconSymbol(name: "Jacket",        symbol: "figure.walk"),
        IconSymbol(name: "Hat",           symbol: "baseball.fill"),
        IconSymbol(name: "Sunglasses",    symbol: "sunglasses.fill"),
        IconSymbol(name: "Gloves",        symbol: "hand.raised.fill"),
        IconSymbol(name: "Scarf",         symbol: "tornado"),
        IconSymbol(name: "Backpack",      symbol: "backpack.fill"),
        IconSymbol(name: "Sneakers",      symbol: "shoeprints.fill"),
        IconSymbol(name: "Watch",         symbol: "applewatch"),
        IconSymbol(name: "Ring",          symbol: "circle.fill"),
    ])

    static let health = IconCategory(name: "Health & Medical", symbols: [
        IconSymbol(name: "Pills",         symbol: "pills.fill"),
        IconSymbol(name: "Syringe",       symbol: "syringe.fill"),
        IconSymbol(name: "Stethoscope",   symbol: "stethoscope"),
        IconSymbol(name: "Heart",         symbol: "heart.fill"),
        IconSymbol(name: "Brain",         symbol: "brain.fill"),
        IconSymbol(name: "Eye",           symbol: "eye.fill"),
        IconSymbol(name: "Bandage",       symbol: "bandage.fill"),
        IconSymbol(name: "Cross",         symbol: "cross.fill"),
        IconSymbol(name: "Thermometer",   symbol: "thermometer.medium"),
        IconSymbol(name: "Inhaler",       symbol: "allergens"),
        IconSymbol(name: "Glasses",       symbol: "eyeglasses"),
        IconSymbol(name: "DNA",           symbol: "staroflife.fill"),
    ])

    static let work = IconCategory(name: "Work & Office", symbols: [
        IconSymbol(name: "Briefcase",     symbol: "briefcase.fill"),
        IconSymbol(name: "Laptop",        symbol: "laptopcomputer"),
        IconSymbol(name: "Calendar",      symbol: "calendar"),
        IconSymbol(name: "Chart",         symbol: "chart.bar.fill"),
        IconSymbol(name: "Document",      symbol: "doc.fill"),
        IconSymbol(name: "Clipboard",     symbol: "clipboard.fill"),
        IconSymbol(name: "Pen",           symbol: "pencil"),
        IconSymbol(name: "Folder",        symbol: "folder.fill"),
        IconSymbol(name: "Badge",         symbol: "person.crop.rectangle.fill"),
        IconSymbol(name: "Headset",       symbol: "headphones"),
        IconSymbol(name: "Printer",       symbol: "printer.fill"),
        IconSymbol(name: "Mail",          symbol: "envelope.fill"),
        IconSymbol(name: "Phone",         symbol: "phone.fill"),
        IconSymbol(name: "Video Call",    symbol: "video.fill"),
        IconSymbol(name: "Building",      symbol: "building.2.fill"),
    ])

    static let education = IconCategory(name: "Education", symbols: [
        IconSymbol(name: "Book",          symbol: "book.fill"),
        IconSymbol(name: "Books",         symbol: "books.vertical.fill"),
        IconSymbol(name: "Graduation",    symbol: "graduationcap.fill"),
        IconSymbol(name: "Pencil",        symbol: "pencil"),
        IconSymbol(name: "Ruler",         symbol: "ruler.fill"),
        IconSymbol(name: "Globe",         symbol: "globe"),
        IconSymbol(name: "Microscope",    symbol: "flask.fill"),
        IconSymbol(name: "Calculator",    symbol: "plus.slash.minus"),
        IconSymbol(name: "Backpack",      symbol: "backpack.fill"),
        IconSymbol(name: "School",        symbol: "building.columns.fill"),
        IconSymbol(name: "Lightbulb",     symbol: "lightbulb.fill"),
    ])

    static let home = IconCategory(name: "Home", symbols: [
        IconSymbol(name: "House",         symbol: "house.fill"),
        IconSymbol(name: "Sofa",          symbol: "sofa.fill"),
        IconSymbol(name: "Bed",           symbol: "bed.double.fill"),
        IconSymbol(name: "Kitchen",       symbol: "stove.fill"),
        IconSymbol(name: "Refrigerator",  symbol: "refrigerator.fill"),
        IconSymbol(name: "Washer",        symbol: "washer.fill"),
        IconSymbol(name: "TV",            symbol: "tv.fill"),
        IconSymbol(name: "Lamp",          symbol: "lamp.floor.fill"),
        IconSymbol(name: "Shower",        symbol: "shower.fill"),
        IconSymbol(name: "Lock",          symbol: "lock.fill"),
        IconSymbol(name: "Key",           symbol: "key.fill"),
        IconSymbol(name: "Hammer",        symbol: "hammer.fill"),
        IconSymbol(name: "Wrench",        symbol: "wrench.fill"),
        IconSymbol(name: "Light Bulb",    symbol: "lightbulb.fill"),
        IconSymbol(name: "Fan",           symbol: "fan.fill"),
        IconSymbol(name: "Plant",         symbol: "leaf.fill"),
    ])

    static let finance = IconCategory(name: "Finance", symbols: [
        IconSymbol(name: "Dollar",        symbol: "dollarsign.circle.fill"),
        IconSymbol(name: "Credit Card",   symbol: "creditcard.fill"),
        IconSymbol(name: "Wallet",        symbol: "wallet.pass.fill"),
        IconSymbol(name: "Bank",          symbol: "building.columns.fill"),
        IconSymbol(name: "Chart Up",      symbol: "chart.line.uptrend.xyaxis"),
        IconSymbol(name: "Safe",          symbol: "lock.rectangle.fill"),
        IconSymbol(name: "Receipt",       symbol: "receipt.fill"),
        IconSymbol(name: "Gift",          symbol: "gift.fill"),
        IconSymbol(name: "Tag",           symbol: "tag.fill"),
        IconSymbol(name: "Cart",          symbol: "cart.fill"),
    ])

    static let nature = IconCategory(name: "Nature & Weather", symbols: [
        IconSymbol(name: "Sun",           symbol: "sun.max.fill"),
        IconSymbol(name: "Moon",          symbol: "moon.fill"),
        IconSymbol(name: "Cloud",         symbol: "cloud.fill"),
        IconSymbol(name: "Rain",          symbol: "cloud.rain.fill"),
        IconSymbol(name: "Snow",          symbol: "snowflake"),
        IconSymbol(name: "Wind",          symbol: "wind"),
        IconSymbol(name: "Umbrella",      symbol: "umbrella.fill"),
        IconSymbol(name: "Leaf",          symbol: "leaf.fill"),
        IconSymbol(name: "Tree",          symbol: "tree.fill"),
        IconSymbol(name: "Flame",         symbol: "flame.fill"),
        IconSymbol(name: "Drop",          symbol: "drop.fill"),
        IconSymbol(name: "Mountain",      symbol: "mountain.2.fill"),
        IconSymbol(name: "Pawprint",      symbol: "pawprint.fill"),
        IconSymbol(name: "Fish",          symbol: "fish.fill"),
        IconSymbol(name: "Bird",          symbol: "bird.fill"),
    ])

    static let sports = IconCategory(name: "Sports", symbols: [
        IconSymbol(name: "Basketball",    symbol: "basketball.fill"),
        IconSymbol(name: "Soccer",        symbol: "soccerball"),
        IconSymbol(name: "Tennis",        symbol: "tennisball.fill"),
        IconSymbol(name: "Baseball",      symbol: "baseball.fill"),
        IconSymbol(name: "Football",      symbol: "football.fill"),
        IconSymbol(name: "Rugby",         symbol: "rugby.ball.fill"),
        IconSymbol(name: "Volleyball",    symbol: "volleyball.fill"),
        IconSymbol(name: "Hockey Puck",   symbol: "hockey.puck.fill"),
        IconSymbol(name: "Golf",          symbol: "figure.golf"),
        IconSymbol(name: "Skiing",        symbol: "figure.skiing.downhill"),
        IconSymbol(name: "Surfing",       symbol: "figure.surfing"),
        IconSymbol(name: "Boxing",        symbol: "figure.boxing"),
        IconSymbol(name: "Archery",       symbol: "figure.archery"),
        IconSymbol(name: "Fencing",       symbol: "figure.fencing"),
        IconSymbol(name: "Climbing",      symbol: "figure.climbing"),
        IconSymbol(name: "Trophy",        symbol: "trophy.fill"),
        IconSymbol(name: "Medal",         symbol: "medal.fill"),
    ])

    static let music = IconCategory(name: "Music & Media", symbols: [
        IconSymbol(name: "Music Note",    symbol: "music.note"),
        IconSymbol(name: "Headphones",    symbol: "headphones"),
        IconSymbol(name: "Speaker",       symbol: "speaker.wave.3.fill"),
        IconSymbol(name: "Microphone",    symbol: "mic.fill"),
        IconSymbol(name: "Guitar",        symbol: "guitars.fill"),
        IconSymbol(name: "Piano",         symbol: "pianokeys.inverse"),
        IconSymbol(name: "Radio",         symbol: "radio.fill"),
        IconSymbol(name: "Record",        symbol: "opticaldisc.fill"),
        IconSymbol(name: "Play",          symbol: "play.circle.fill"),
        IconSymbol(name: "Podcast",       symbol: "dot.radiowaves.left.and.right"),
        IconSymbol(name: "AirPlay",       symbol: "airplayvideo"),
    ])

    static let people = IconCategory(name: "People & Social", symbols: [
        IconSymbol(name: "Person",        symbol: "person.fill"),
        IconSymbol(name: "People",        symbol: "person.2.fill"),
        IconSymbol(name: "Family",        symbol: "figure.2.and.child.holdinghands"),
        IconSymbol(name: "Baby",          symbol: "figure.and.child.holdinghands"),
        IconSymbol(name: "Message",       symbol: "message.fill"),
        IconSymbol(name: "Phone Call",    symbol: "phone.fill"),
        IconSymbol(name: "Video Call",    symbol: "video.fill"),
        IconSymbol(name: "Heart",         symbol: "heart.fill"),
        IconSymbol(name: "Star",          symbol: "star.fill"),
        IconSymbol(name: "Party",         symbol: "party.popper.fill"),
        IconSymbol(name: "Birthday",      symbol: "birthday.cake.fill"),
        IconSymbol(name: "Gift",          symbol: "gift.fill"),
    ])

    static let safety = IconCategory(name: "Safety & Security", symbols: [
        IconSymbol(name: "Shield",        symbol: "shield.fill"),
        IconSymbol(name: "Lock",          symbol: "lock.fill"),
        IconSymbol(name: "Eye",           symbol: "eye.fill"),
        IconSymbol(name: "Bell",          symbol: "bell.fill"),
        IconSymbol(name: "Alarm",         symbol: "alarm.fill"),
        IconSymbol(name: "SOS",           symbol: "sos"),
        IconSymbol(name: "First Aid",     symbol: "cross.fill"),
        IconSymbol(name: "Fire",          symbol: "flame.fill"),
        IconSymbol(name: "Flashlight",    symbol: "flashlight.on.fill"),
        IconSymbol(name: "Location",      symbol: "location.fill"),
    ])

    static let misc = IconCategory(name: "Misc", symbols: [
        IconSymbol(name: "Star",          symbol: "star.fill"),
        IconSymbol(name: "Heart",         symbol: "heart.fill"),
        IconSymbol(name: "Lightning",     symbol: "bolt.fill"),
        IconSymbol(name: "Flag",          symbol: "flag.fill"),
        IconSymbol(name: "Tag",           symbol: "tag.fill"),
        IconSymbol(name: "Bookmark",      symbol: "bookmark.fill"),
        IconSymbol(name: "Pin",           symbol: "pin.fill"),
        IconSymbol(name: "Bell",          symbol: "bell.fill"),
        IconSymbol(name: "Gear",          symbol: "gearshape.fill"),
        IconSymbol(name: "Checkmark",     symbol: "checkmark.circle.fill"),
        IconSymbol(name: "Clock",         symbol: "clock.fill"),
        IconSymbol(name: "Calendar",      symbol: "calendar"),
        IconSymbol(name: "Magnifier",     symbol: "magnifyingglass"),
        IconSymbol(name: "Share",         symbol: "square.and.arrow.up"),
        IconSymbol(name: "Plus",          symbol: "plus.circle.fill"),
        IconSymbol(name: "Trash",         symbol: "trash.fill"),
        IconSymbol(name: "Archive",       symbol: "archivebox.fill"),
        IconSymbol(name: "Infinity",      symbol: "infinity"),
        IconSymbol(name: "Sparkles",      symbol: "sparkles"),
        IconSymbol(name: "Wand",          symbol: "wand.and.stars"),
    ])
}