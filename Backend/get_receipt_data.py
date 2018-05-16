########### Python 2.7 #############
import httplib, urllib, base64, json, sys

def insertionSort(alist):
    for i in range(1, len(alist)):
        current_node = alist[i]
        current_value = int(alist[i]['average'])
        pos = i
        changed = False
        while pos > 0 and current_value < int(alist[pos-1]['average']):
            alist[pos] = alist[pos-1]
            pos -= 1
            changed = True
        if changed:
            alist[pos] = current_node


def insertionSort2(alist):
    for i in range(1, len(alist)):
        current_node = alist[i]
        current_value = int(alist[i]['boundingBox'].split(",")[0])

        # print "currently at " +  str(current_node)
        pos = i
        changed = False
        while pos > 0:
            prev_val = int(alist[pos-1]['boundingBox'].split(",")[0])
            if current_value < prev_val:
                # print current_value + " is smaller than " + prev_val
                alist[pos] = alist[pos-1]
                pos -= 1
                changed = True
            else:
                break
        if changed:
            alist[pos] = current_node
            # print "new list: " + str(alist)

def is_an_item(alist):
    last_element = alist[len(alist)-1]
    if isinstance(last_element, bool):
        return False
    if "$" in last_element:
        return True
    if len(last_element) < 4:
        return False
    if len(alist) < 2:
        return False
    if "Total:" in alist or "Total" in alist:
        return False
    if last_element[-3] == '.' or last_element[-3] == ',':
        return True
    return False

###############################################
#### Update or verify the following values. ###
###############################################

# Replace the subscription_key string value with your valid subscription key.
subscription_key = '363d9bd2f51a46b48d6d9c9c593aef45'

# Replace or verify the region.
#
# You must use the same region in your REST API call as you used to obtain your subscription keys.
# For example, if you obtained your subscription keys from the westus region, replace
# "westcentralus" in the URI below with "westus".
#
# NOTE: Free trial subscription keys are generated in the westcentralus region, so if you are using
# a free trial subscription key, you should not need to change this region.
uri_base = "westcentralus.api.cognitive.microsoft.com"
parsed_data = {}

headers = {
    # Request headers.
    'Content-Type': 'application/json',
    'Ocp-Apim-Subscription-Key': subscription_key,
}

params = urllib.urlencode({
    # Request parameters. The language setting "unk" means automatically detect the language.
    'language': 'unk',
    'detectOrientation ': 'true',
})

# The URL of a JPEG image containing text.
body = "{'url':'" + sys.argv[1] + "'}"

try:
    # Execute the REST API call and get the response.
    conn = httplib.HTTPSConnection(uri_base)
    conn.request("POST", "/vision/v1.0/ocr?%s" % params, body, headers)
    response = conn.getresponse()
    data = response.read()
    parsed_data = json.loads(data)

    # 'data' contains the JSON data. The following formats the JSON data for display.

    conn.close()


except Exception as e:
    print('Error:')
    print(e)


rows = []
for region in parsed_data['regions']:
    for line in region['lines']:
        words = line['words']
        average = 0;
        for word in words:
            coordinates = word["boundingBox"].split(",")
            average += int(coordinates[1])
        average /= len(words)
        rows.append({"average": average, "words" : words})
# print rows
# print ""


difference_threshhold = 20
rows2 = []
changes = 0;
for row in rows:
    parsed = False
    # print (" ")
    # print("Now on row: " + str(row))
    for i, row2 in enumerate(rows2):
        # print("comparing to row: " + str(row2))
        average1 = row['average']
        average2 = row2['average']
        # print (str(average1) + " - " + str(average2) + " = " + str(abs(average1 - average2)))
        if abs(average1 - average2) <= difference_threshhold:
            # print("Adding to this existing cluster")
            new_average = average1*len(row['words'])+average2*len(row2['words'])
            new_average/= len(row['words'])+len(row2['words'])
            new_entry = {"average":new_average, "words":row['words'] + row2['words']}
            rows2[i]= new_entry
            parsed = True
            # print ("row is now: " + str(new_entry))
            break;
        # else :
            # print ("difference too big looking for another")
    if not parsed:
        # print("this is a new cluster")
        rows2.append(row)
# print rows2
# print ""


insertionSort(rows2)
for row in rows2:
    insertionSort2(row['words'])
# print rows2
# print ""


filtered_rows = []
for row in rows2:
    the_words = row['words']
    arr = []
    for word in the_words:
        arr.append(word['text'])
    filtered_rows.append(arr)
print filtered_rows
print " "

items = []
for row in filtered_rows:
    if is_an_item(row):
        name = ""
        for i in range(0, len(row) - 1):
            name += row[i]+" "
        items.append({"item":name[:-1], "price":row[len(row)-1]})


temp_total = 0
for i in filtered_rows:
    if 'Total' in i or 'TOTAL' in i or 'Total:' in i or 'TOTAL:' in i or 'TOTAL--->' in i or 'PAID' in i:
        for j in range(0, len(i)):
            try:
                total_val = i[j].replace("$", "").replace(" ", "")

                if ',' in i[j] and '.' not in i[j]: #condition that satisfies a value that has totals that use commas for decimals
                    total_val = total_val.replace(',', '.') #replaces the comma with a decimal

                if '.' in total_val:
                    temp_total = max(temp_total, float(total_val))
            except ValueError:
                pass



result = {'total': temp_total, 'items':items}
print result
