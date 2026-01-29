String requestStatusLabel(String status) {
  switch (status) {
    case 'open':
      return 'Open';
    case 'closed':
      return 'Closed';
    case 'awarded':
      return 'Awarded';
    case 'cancelled':
      return 'Cancelled';
    default:
      if (status.trim().isEmpty) return 'Unknown';
      return status.replaceAll('_', ' ');
  }
}

String offerStatusLabel(String status) {
  switch (status) {
    case 'active':
      return 'Active';
    case 'inactive':
      return 'Inactive';
    default:
      if (status.trim().isEmpty) return 'Unknown';
      return status.replaceAll('_', ' ');
  }
}

String quotationStatusLabel(String status) {
  switch (status) {
    case 'created':
      return 'Created';
    case 'accepted':
      return 'Accepted';
    case 'rejected_by_user':
      return 'Rejected (by user)';
    case 'cancelled_by_company':
      return 'Cancelled (by company)';
    default:
      if (status.trim().isEmpty) return 'Unknown';
      return status.replaceAll('_', ' ');
  }
}
