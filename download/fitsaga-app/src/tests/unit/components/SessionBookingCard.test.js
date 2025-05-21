/**
 * Unit tests for the SessionBookingCard component
 */
import React from 'react';
import { render, fireEvent } from '@testing-library/react-native';
import SessionBookingCard from '../../../components/sessions/SessionBookingCard';

// Mock the navigation hook
jest.mock('@react-navigation/native', () => ({
  useNavigation: () => ({
    navigate: jest.fn(),
  }),
}));

describe('SessionBookingCard Component', () => {
  // Default test props
  const defaultProps = {
    session: {
      id: 'session123',
      title: 'Power Yoga',
      activityType: 'yoga',
      instructorName: 'Jane Smith',
      startTime: new Date('2025-05-21T10:00:00'),
      endTime: new Date('2025-05-21T11:00:00'),
      capacity: 20,
      enrolledCount: 12,
      location: 'Studio A',
      creditCost: 2,
    },
    userCredits: {
      gymCredits: 5,
      intervalCredits: 3,
    },
    onBookPress: jest.fn(),
    disabled: false,
  };

  test('renders correctly with session details', () => {
    const { getByText } = render(<SessionBookingCard {...defaultProps} />);
    
    // Check that session details are displayed
    expect(getByText('Power Yoga')).toBeTruthy();
    expect(getByText('Jane Smith')).toBeTruthy();
    expect(getByText('Studio A')).toBeTruthy();
    expect(getByText('12/20')).toBeTruthy(); // enrolled/capacity
    expect(getByText('2')).toBeTruthy(); // credit cost
  });

  test('formats time correctly', () => {
    const { getByText } = render(<SessionBookingCard {...defaultProps} />);
    
    // Time formatting will depend on your implementation, this is an example
    expect(getByText('10:00 AM - 11:00 AM')).toBeTruthy();
  });

  test('displays available spots correctly', () => {
    const { getByText } = render(<SessionBookingCard {...defaultProps} />);
    
    // 20 capacity - 12 enrolled = 8 spots available
    expect(getByText('8 spots left')).toBeTruthy();
  });

  test('shows "Book" button when not booked', () => {
    const { getByText } = render(<SessionBookingCard {...defaultProps} />);
    
    const bookButton = getByText('Book');
    expect(bookButton).toBeTruthy();
  });
  
  test('shows "Booked" indicator when already booked', () => {
    const propsWithBooked = {
      ...defaultProps,
      session: {
        ...defaultProps.session,
        isBooked: true,
      },
    };
    
    const { getByText } = render(<SessionBookingCard {...propsWithBooked} />);
    
    expect(getByText('Booked')).toBeTruthy();
  });

  test('shows "Full" indicator when session is at capacity', () => {
    const propsWithFullSession = {
      ...defaultProps,
      session: {
        ...defaultProps.session,
        capacity: 12,
        enrolledCount: 12,
      },
    };
    
    const { getByText } = render(<SessionBookingCard {...propsWithFullSession} />);
    
    expect(getByText('Full')).toBeTruthy();
  });

  test('calls onBookPress when book button is pressed', () => {
    const mockOnBookPress = jest.fn();
    const props = {
      ...defaultProps,
      onBookPress: mockOnBookPress,
    };
    
    const { getByText } = render(<SessionBookingCard {...props} />);
    
    const bookButton = getByText('Book');
    fireEvent.press(bookButton);
    
    expect(mockOnBookPress).toHaveBeenCalledWith(props.session);
  });

  test('disables book button when disabled prop is true', () => {
    const props = {
      ...defaultProps,
      disabled: true,
    };
    
    const { getByTestId } = render(<SessionBookingCard {...props} />);
    
    const bookButton = getByTestId('book-button');
    expect(bookButton.props.disabled).toBe(true);
  });

  test('shows warning when user has insufficient credits', () => {
    const propsWithLowCredits = {
      ...defaultProps,
      userCredits: {
        gymCredits: 1,
        intervalCredits: 0,
      },
    };
    
    const { getByText } = render(<SessionBookingCard {...propsWithLowCredits} />);
    
    expect(getByText('Insufficient credits')).toBeTruthy();
  });

  test('prioritizes interval credits when available', () => {
    const props = {
      ...defaultProps,
      session: {
        ...defaultProps.session,
        creditCost: 2,
      },
      userCredits: {
        gymCredits: 5,
        intervalCredits: 3,
      },
    };
    
    const { getByText } = render(<SessionBookingCard {...props} />);
    
    // This test assumes your component shows which credit type will be used
    expect(getByText('Using interval credits')).toBeTruthy();
  });

  test('falls back to gym credits when interval credits are insufficient', () => {
    const props = {
      ...defaultProps,
      session: {
        ...defaultProps.session,
        creditCost: 4,
      },
      userCredits: {
        gymCredits: 5,
        intervalCredits: 3,
      },
    };
    
    const { getByText } = render(<SessionBookingCard {...props} />);
    
    // This test assumes your component shows which credit type will be used
    expect(getByText('Using gym credits')).toBeTruthy();
  });
});