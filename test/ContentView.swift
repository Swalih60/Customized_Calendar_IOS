import SwiftUI

struct CalendarView: View {
    @State private var selectedDates: [Date] = []
    @State private var isDragging = false
    @State private var dragStartDate: Date?
    @State private var currentMonth = Date()
    @State private var showingMonths = 2
    @State private var selectionState: SelectionState = .none // Add selection state tracking
    
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    private let weekdayFormatter = DateFormatter()
    private let monthYearFormatter = DateFormatter()
    
    // Define selection states
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
                    }
                    
                    Text("Select Date")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("calendarColor"))
                        
                    
                    Spacer()
                }
                .padding()
                
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
                        VStack(alignment: .leading) {
                            Text("Departure")
                                .foregroundColor(.gray)
                                .font(.caption)
                            Text(formattedDate(selectedDates.first))
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                        
                        VStack(alignment: .leading) {
                            Text("Return")
                                .foregroundColor(.gray)
                                .font(.caption)
                            Text(selectedDates.count > 1 ? formattedDate(selectedDates.last) : "MMM DD, YYYY")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                    }
                    .padding()
                    
                    Button(action: {
                        // Apply action
                    }) {
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
                            )
)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                
                }
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -5)
            }
            .background(Color.white)
            .navigationBarHidden(true)
        }
    }
    
    private func monthView(for date: Date) -> some View {
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let monthOnly = date.formatted(.dateTime.month(.wide))
        let yearOnly = date.formatted(.dateTime.year())
        let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)!.count
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let adjustedFirstWeekday = (firstWeekday + 5) % 7 // Adjusting to make Monday = 0
        
        return VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .firstTextBaseline) {
                Text(monthOnly)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("calendarColor"))
                Text(yearOnly)
                    .font(.subheadline)
                    .foregroundColor(Color("calendarColor"))
            }
            .padding(.horizontal)
            
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"], id: \.self) { day in
                    Text(day)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color("calendarColor"))
                }
            }
            
            // Days grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
                // Empty cells for days before the first of month
                ForEach(0..<adjustedFirstWeekday, id: \.self) { _ in
                    Color.clear
                        .aspectRatio(1, contentMode: .fit)
                }
                
                // Days of the month
                ForEach(1...daysInMonth, id: \.self) { day in
                    let currentDate = calendar.date(byAdding: .day, value: day - 1, to: monthStart)!
                    dayCell(for: currentDate)
                        .aspectRatio(1, contentMode: .fit)
                }
            }
        }
    }
    
    private func dayCell(for date: Date) -> some View {
        let day = calendar.component(.day, from: date)
        let isSelected = isDateSelected(date)
        let isPastDate = calendar.compare(date, to: Date(), toGranularity: .day) == .orderedAscending
        
        return Text("\(day)")
            .font(.body)
            .fontWeight(isSelected ? .bold : .regular)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                isSelected ? RoundedRectangle(cornerRadius: 4).fill(Color.blue) : nil
            )
            .foregroundColor(isSelected ? .white : (isPastDate ? .gray : .primary))
            .opacity(isPastDate ? 0.5 : 1.0)
            .contentShape(Rectangle()) // Make entire cell tappable
            .onTapGesture {
                if !isPastDate {
                    handleDateSelection(date)
                }
            }
    }
    
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
    
    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "MMM DD, YYYY" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}



struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
