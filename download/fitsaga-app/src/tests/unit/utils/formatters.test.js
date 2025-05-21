/**
 * Unit tests for formatting utility functions
 */

// Define simple formatter functions for testing
const formatters = {
  // Format date to string
  formatDate: (date) => {
    return date.toLocaleDateString('en-US', {
      month: 'long',
      day: 'numeric',
      year: 'numeric'
    });
  },
  
  // Format time to string
  formatTime: (date) => {
    return date.toLocaleTimeString('en-US', {
      hour: 'numeric',
      minute: '2-digit', 
      hour12: true
    }).replace(' ', '');
  },
  
  // Format price to currency
  formatCurrency: (amount) => {
    return `$${amount.toFixed(2)}`;
  },
  
  // Calculate percentage
  calculatePercentage: (value, total) => {
    return Math.round((value / total) * 100);
  },
  
  // Format duration in minutes to hours and minutes
  formatDuration: (minutes) => {
    if (minutes < 60) {
      return `${minutes} min`;
    }
    
    const hours = Math.floor(minutes / 60);
    const remainingMinutes = minutes % 60;
    
    if (remainingMinutes === 0) {
      return `${hours} hr`;
    }
    
    return `${hours} hr ${remainingMinutes} min`;
  }
};

describe('Formatter Utilities', () => {
  describe('formatDate', () => {
    test('formats date correctly', () => {
      const date = new Date(2025, 4, 21); // May 21, 2025
      const formattedDate = formatters.formatDate(date);
      expect(formattedDate).toBe('May 21, 2025');
    });
    
    test('handles different dates', () => {
      const date1 = new Date(2025, 0, 1); // January 1, 2025
      const date2 = new Date(2025, 11, 31); // December 31, 2025
      
      expect(formatters.formatDate(date1)).toBe('January 1, 2025');
      expect(formatters.formatDate(date2)).toBe('December 31, 2025');
    });
  });
  
  describe('formatTime', () => {
    test('formats time correctly', () => {
      const date = new Date(2025, 4, 21, 15, 30, 0); // May 21, 2025, 15:30:00
      const formattedTime = formatters.formatTime(date);
      expect(formattedTime).toBe('3:30PM');
    });
    
    test('handles AM/PM correctly', () => {
      const morningTime = new Date(2025, 4, 21, 8, 15, 0); // 8:15 AM
      const noonTime = new Date(2025, 4, 21, 12, 0, 0); // 12:00 PM
      const afternoonTime = new Date(2025, 4, 21, 17, 45, 0); // 5:45 PM
      const midnightTime = new Date(2025, 4, 21, 0, 0, 0); // 12:00 AM
      
      expect(formatters.formatTime(morningTime)).toBe('8:15AM');
      expect(formatters.formatTime(noonTime)).toBe('12:00PM');
      expect(formatters.formatTime(afternoonTime)).toBe('5:45PM');
      expect(formatters.formatTime(midnightTime)).toBe('12:00AM');
    });
  });
  
  describe('formatCurrency', () => {
    test('formats currency correctly', () => {
      expect(formatters.formatCurrency(10)).toBe('$10.00');
      expect(formatters.formatCurrency(10.5)).toBe('$10.50');
      expect(formatters.formatCurrency(10.59)).toBe('$10.59');
      expect(formatters.formatCurrency(0)).toBe('$0.00');
    });
  });
  
  describe('calculatePercentage', () => {
    test('calculates percentage correctly', () => {
      expect(formatters.calculatePercentage(5, 10)).toBe(50);
      expect(formatters.calculatePercentage(1, 4)).toBe(25);
      expect(formatters.calculatePercentage(3, 3)).toBe(100);
      expect(formatters.calculatePercentage(0, 10)).toBe(0);
    });
    
    test('handles rounding', () => {
      expect(formatters.calculatePercentage(1, 3)).toBe(33); // 33.33...%
      expect(formatters.calculatePercentage(2, 3)).toBe(67); // 66.66...%
    });
  });
  
  describe('formatDuration', () => {
    test('formats duration correctly', () => {
      expect(formatters.formatDuration(30)).toBe('30 min');
      expect(formatters.formatDuration(60)).toBe('1 hr');
      expect(formatters.formatDuration(90)).toBe('1 hr 30 min');
      expect(formatters.formatDuration(120)).toBe('2 hr');
      expect(formatters.formatDuration(150)).toBe('2 hr 30 min');
    });
  });
});