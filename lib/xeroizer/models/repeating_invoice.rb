require "xeroizer/models/attachment"

module Xeroizer
  module Record

    class RepeatingInvoiceModel < BaseModel

      set_permissions :read

      include AttachmentModel::Extensions

    end

    class RepeatingInvoice < Base

      INVOICE_TYPE = {
        'ACCREC' => 'Accounts Receivable',
        'ACCPAY' => 'Accounts Payable'
      } unless defined?(INVOICE_TYPE)
      INVOICE_TYPES = INVOICE_TYPE.keys.sort

      INVOICE_STATUS = {
        'AUTHORISED' => 'Approved invoices awaiting payment',
        'DRAFT' =>      'Invoices saved as draft or entered via API',
      } unless defined?(INVOICE_STATUS)
      INVOICE_STATUSES = INVOICE_STATUS.keys.sort

      include Attachment::Extensions

      set_primary_key :repeating_invoice_id
      set_possible_primary_keys :repeating_invoice_id
      list_contains_summary_only false

      guid    :repeating_invoice_id
      string  :reference
      guid    :branding_theme_id
      string  :type
      string  :status
      string  :line_amount_types
      decimal :sub_total, :calculated => true
      decimal :total_tax, :calculated => true
      decimal :total, :calculated => true
      string  :currency_code
      boolean :has_attachments

      belongs_to :contact
      belongs_to :schedule
      has_many   :line_items, :complete_on_page => true

      validates_inclusion_of :type, :in => INVOICE_TYPES
      validates_inclusion_of :status, :in => INVOICE_STATUSES, :unless => :new_record?
      validates_inclusion_of :line_amount_types, :in => LINE_AMOUNT_TYPES, :unless => :new_record?
      validates_associated :schedule
      validates_associated :contact
      validates_associated :line_items, :allow_blanks => true, :unless => :approved?
      validates_associated :line_items, :if => :approved?

      public

        # Access the contact name without forcing a download of
        # an incomplete, summary invoice.
        def contact_name
          attributes[:contact] && attributes[:contact][:name]
        end

        # Access the contact ID without forcing a download of an
        # incomplete, summary invoice.
        def contact_id
          attributes[:contact] && attributes[:contact][:contact_id]
        end

        # Helper method to check if the invoice has been approved.
        def approved?
          [ 'AUTHORISED' ].include? status
        end

        # Helper method to check if the invoice is accounts payable.
        def accounts_payable?
          type == 'ACCPAY'
        end

        # Helper method to check if the invoice is accounts receivable.
        def accounts_receivable?
          type == 'ACCREC'
        end

    end

  end
end
