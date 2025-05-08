import SwiftUI

struct CalendarView: View {
    @State private var selectedDates: [Date] = []
    @State private var isDragging = false
    @State private var dragStartDate: Date?
    @State private var currentMonth = Date()
    @State private var showingMonths = 12
    @State private var selectionState: SelectionState = .none
    @State private var scrollOffset: CGFloat = 0
    @State private var timeSelection:Bool=true
    
    @State private var selectedTime1=Date()
    @State private var showTimePicker1: Bool = false
    @State private var selectedTime2=Date()
    @State private var showTimePicker2: Bool = false

    
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    private let weekdayFormatter = DateFormatter()
    private let monthYearFormatter = DateFormatter()
    
    // Different states of selection in calendar
    private enum SelectionState {
        case none
        case firstDateSelected
        case rangeSelected
    }
    
    init() {
        dateFormatter.dateFormat = "d"
        weekdayFormatter.dateFormat = "E"
        monthYearFormatter.dateFormat = "MMM yyyy"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with back button
                HStack {
                    Button(action: {
                        // Go back action
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                            .font(.title2)
                    }.padding()
                    
                    Text("Select Date")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color("calendarColor"))
                        
                    
                    Spacer()
                }
                .padding(.bottom,20)
                
                // Sticky weekday header
                HStack(spacing: 0) {
                    ForEach(["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"], id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .fontWeight(.regular)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color("calendarColor"))
                    }
                }
                .padding(.bottom, 30)
                .background(Color.white)
                .zIndex(1)
                
                //Calendar main part
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(0..<showingMonths, id: \.self) { monthOffset in
                            let date = calendar.date(byAdding: .month, value: monthOffset, to: currentMonth)!
                            monthView(for: date)
                        }
                    }
                    .padding(.bottom, 100)
                }
                
                // Footer with date selection and apply button
                VStack(spacing: 0) {
                    HStack(spacing: 10) {
                        //Component defined at the bottom
                       DateAndTime(showTimePicker: $showTimePicker1, selectedTime: $selectedTime1, timeSelection: $timeSelection, selectedDates: $selectedDates, label: "Departure")
                        
                        DateAndTime(showTimePicker: $showTimePicker2, selectedTime: $selectedTime2, timeSelection: $timeSelection, selectedDates: $selectedDates, label: "Return")
                    }
                    .padding()
                    
                    Button(action: {
                        // Apply action
                    }) {
                        ApplyButton()
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .background(Color.white)
            }
            .background(LinearGradient(
                gradient: Gradient(colors: [
                    Color(.white),
                    Color(UIColor.systemGray6)
                ]),
                startPoint: .top,
                endPoint: .bottom
            ))
            .navigationBarHidden(true)
        }
    }
    
    //Main part that is the Month title and the numbers this is repeated by passing values in the main code
    private func monthView(for date: Date) -> some View {
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let monthOnly = date.formatted(.dateTime.month(.wide))
        let yearOnly = date.formatted(.dateTime.year())
        let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)!.count
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let adjustedFirstWeekday = (firstWeekday + 5) % 7 // Adjusting to make Monday = 0, Sunday = 6
        
        return VStack(alignment: .trailing, spacing: 20) {
            HStack(alignment: .firstTextBaseline) {
                Text(monthOnly)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("calendarColor"))
                Text(yearOnly)
                    .font(.caption)
                    .foregroundColor(Color("calendarColor"))
                    .fontWeight(.bold)
            }
            .padding(.horizontal)
            
            // Days grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
                // Empty cells for days before the first of month
                ForEach(0..<adjustedFirstWeekday, id: \.self) { index in
                    Color.clear
                        .aspectRatio(1, contentMode: .fit)
                        .id("empty-\(date)-\(index)")
                }
                
                // Days of the month
                ForEach(1...daysInMonth, id: \.self) { day in
                    let currentDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: monthStart), month: calendar.component(.month, from: monthStart), day: day))!
                    dayCell(for: currentDate)
                        .aspectRatio(1, contentMode: .fit)
                        .id("day-\(date)-\(day)")
                }
            }
        }
    }
    
    
    //For each number in the calendar setting there background and there color
    private func dayCell(for date: Date) -> some View {
        let day = calendar.component(.day, from: date)
       
        let isEndpoint = isDateEndpoint(date)
        let isInRange = isDateInRange(date)
        let isPastDate = calendar.compare(date, to: Date(), toGranularity: .day) == .orderedAscending
        
        return Text("\(day)")
            .font(.caption)
            
           
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Group {
                    if isEndpoint {
                        RoundedRectangle(cornerRadius: 4)
                            
                            .fill(Color("calendarHighlightTile"))
                            .frame(width: 40,height: 40)
                            
                    } else if isInRange {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color("calendarSelectedTile"))
                            .frame(width: 40,height: 40)
                    } else {
                        Color.clear
                    }
                }
            )
            .foregroundColor(
                isEndpoint ? .white :
                (isInRange ? .primary :
                 (isPastDate ? .gray : Color("numberColor")))
            )
            .opacity(isPastDate ? 0.5 : 1.0)
            .contentShape(Rectangle()) // Make entire cell tappable
            .onTapGesture {
                if !isPastDate {
                    handleDateSelection(date)
                }
            }
    }
    
    //Handling the slection of dates
    private func handleDateSelection(_ date: Date) {
        switch selectionState {
        case .none:
            // First date selected
            selectedDates = [date]
            selectionState = .firstDateSelected
            
        case .firstDateSelected:
            // Second date selected, create range
            if calendar.isDate(date, inSameDayAs: selectedDates[0]) {
                // If tapping the same date again, just keep it selected
                return
            }
            
            let startDate = min(date, selectedDates[0])
            let endDate = max(date, selectedDates[0])
            selectedDates = createDateRange(from: startDate, to: endDate)
            selectionState = .rangeSelected
            
        case .rangeSelected:
            // Clear previous selection, start fresh
            selectedDates = [date]
            selectionState = .firstDateSelected
        }
    }
    
    
    //To create the range of date and pass it to the above code
    private func createDateRange(from startDate: Date, to endDate: Date) -> [Date] {
        var dates: [Date] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            // Skip past dates
            if calendar.compare(currentDate, to: Date(), toGranularity: .day) != .orderedAscending {
                dates.append(currentDate)
            }
            
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return dates
    }
    
    private func isDateSelected(_ date: Date) -> Bool {
        selectedDates.contains { calendar.isDate($0, inSameDayAs: date) }
    }
    
    private func isDateEndpoint(_ date: Date) -> Bool {
        guard selectedDates.count >= 2 else {
            return isDateSelected(date)
        }
        
        return calendar.isDate(date, inSameDayAs: selectedDates.first!) ||
               calendar.isDate(date, inSameDayAs: selectedDates.last!)
    }
    
    private func isDateInRange(_ date: Date) -> Bool {
        guard selectedDates.count >= 2,
              let firstDate = selectedDates.first,
              let lastDate = selectedDates.last else {
            return false
        }
        
        return calendar.compare(date, to: firstDate, toGranularity: .day) != .orderedAscending &&
               calendar.compare(date, to: lastDate, toGranularity: .day) != .orderedDescending &&
               !calendar.isDate(date, inSameDayAs: firstDate) &&
               !calendar.isDate(date, inSameDayAs: lastDate)
    }
    
   
}
//To format Date
private func formattedDate(_ date: Date?) -> String {
    guard let date = date else { return "MMM DD, YYYY" }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d, yyyy"
    return formatter.string(from: date)
}

//Function for formatting the time that is to be showed below the month
private func formattedTime(_ date: Date) -> String {
     let formatter = DateFormatter()
     formatter.dateFormat = "h:mm a"
     return formatter.string(from: date)
 }

//Component for Footer Date and time Tiles
struct DateAndTime: View {
    @Binding var showTimePicker:Bool
    @Binding var selectedTime:Date
    
    @Binding var timeSelection:Bool
    @Binding var selectedDates: [Date]
    let label:String
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .foregroundColor(.gray)
                .font(.caption)
            label=="Departure" ? Text(formattedDate(selectedDates.first)).font(.headline) : Text(selectedDates.count > 1 ? formattedDate(selectedDates.last) : "MMM DD, YYYY")
                .font(.headline)
            if timeSelection {
                // Where you have the time display
                Text(formattedTime(selectedTime))
                
                    .font(.subheadline)
                    
                
                // Then at the end of your body
                    .sheet(isPresented:$showTimePicker) {
                        VStack {
                            DatePicker(
                                "Select Time",
                                selection:$selectedTime,
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                            .padding()
                            
                            Button("Done") {
                               
                                    showTimePicker=false
                                
                            }
                            .padding()
                        }
                        .presentationDetents([.height(250)])
                    }
            }
        }
        .onTapGesture {
          
                showTimePicker=true
            
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(8)
    }
}

//Apply Button
struct ApplyButton: View {
    var body: some View {
        Text("Apply")
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 253/255, green: 104/255, blue: 14/255, opacity: 1.0),
                    Color(red: 218/255, green: 69/255, blue: 1/255, opacity: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .cornerRadius(8)
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}



