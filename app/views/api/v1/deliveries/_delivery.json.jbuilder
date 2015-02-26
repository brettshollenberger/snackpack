json.extract! delivery, :id, :status, :template_id, :campaign_id

json.recipient do
  json.partial! 'api/v1/recipients/recipient', recipient: delivery.recipient
end
