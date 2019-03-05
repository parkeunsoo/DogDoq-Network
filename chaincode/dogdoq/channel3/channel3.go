/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

/*
 * The sample smart contract for documentation topic:
 * Writing Your First Blockchain Application
 */

package main

/* Imports
 * 4 utility libraries for formatting, handling bytes, reading and writing JSON, and string manipulation
 * 2 specific Hyperledger Fabric specific libraries for Smart Contracts
 */
import (
	"bytes"
	"encoding/json"
	"fmt"
	"github.com/hyperledger/fabric/core/chaincode/shim"
	sc "github.com/hyperledger/fabric/protos/peer"
)

// Define the Smart Contract structure
type SmartContract struct {
}

// Define the car structure, with 4 properties.  Structure tags are used by encoding/json library

type Document struct {
	Hash   string `json:"hash"`
	UTF8   string `json:"utf8"`
	Name   string `json:"name"`
	Date   string `json:"date"`
}

/*
 * The Init method is called when the Smart Contract "fabcar" is instantiated by the blockchain network
 * Best practice is to have any Ledger initialization in separate function -- see initLedger()
 */
func (s *SmartContract) Init(APIstub shim.ChaincodeStubInterface) sc.Response {
	return shim.Success(nil)
}

/*
 * The Invoke method is called as a result of an application request to run the Smart Contract "fabcar"
 * The calling application program has also specified the particular smart contract function to be called, with arguments
 */
func (s *SmartContract) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {

	// Retrieve the requested Smart Contract function and arguments
	function, args := APIstub.GetFunctionAndParameters()
	// Route to the appropriate handler function to interact with the ledger appropriately
	if function == "queryHealthcare"{
		return s.queryHealthcare(APIstub, args)
	} else if function == "queryAllHealthcare"{
		return s.queryAllHealthcare(APIstub, args)
	} else if function == "queryBloodline"{
		return s.queryBloodline(APIstub, args)
	} else if function == "queryDiagnostic"{
		return s.queryDiagnostic(APIstub, args)
	} else if function == "queryAllDiagnostic"{
		return s.queryAllDiagnostic(APIstub, args)
	} else if function == "createHealthcare"{
		return s.createHealthcare(APIstub, args)
	} else if function == "createBloodline"{
		return s.createBloodline(APIstub, args)
	} else if function == "createDiagnostic"{
		return s.createDiagnostic(APIstub, args)
	} 

	return shim.Error("Invalid Smart Contract function name.")
}

// query document
func (s *SmartContract) queryHealthcare(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	HealthDoqAsBytes, _ := APIstub.GetState(args[0]+"Health"+args[1])
	return shim.Success(HealthDoqAsBytes)
}
func (s *SmartContract) queryAllHealthcare(APIstub shim.ChaincodeStubInterface, args[]string) sc.Response {

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	startKey := args[0]+"Health0"
	endKey := args[0]+"Health"+args[1]

	resultsIterator, err := APIstub.GetStateByRange(startKey, endKey)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing QueryResults
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"Key\":")
		buffer.WriteString("\"")
		buffer.WriteString(queryResponse.Key)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Record\":")
		// Record is a JSON object, so we write as-is
		buffer.WriteString(string(queryResponse.Value))
		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	fmt.Printf("- queryAllHealthcare:\n%s\n", buffer.String())

	return shim.Success(buffer.Bytes())
}
func (s *SmartContract) queryBloodline(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	BloodDoqAsBytes, _ := APIstub.GetState(args[0]+"Blood")
	return shim.Success(BloodDoqAsBytes)
}

func (s *SmartContract) queryDiagnostic(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	DiagnosticDoqAsBytes, _ := APIstub.GetState(args[0]+"Diagnostic"+args[1])
	return shim.Success(DiagnosticDoqAsBytes)
}
func (s *SmartContract) queryAllDiagnostic(APIstub shim.ChaincodeStubInterface, args[]string) sc.Response {

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	startKey := args[0]+"Diagnostic0"
	endKey := args[0]+"Diagnostic"+args[1]

	resultsIterator, err := APIstub.GetStateByRange(startKey, endKey)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing QueryResults
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"Key\":")
		buffer.WriteString("\"")
		buffer.WriteString(queryResponse.Key)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Record\":")
		// Record is a JSON object, so we write as-is
		buffer.WriteString(string(queryResponse.Value))
		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	fmt.Printf("- queryAllDiagnostic:\n%s\n", buffer.String())

	return shim.Success(buffer.Bytes())
}
// create document
func (s *SmartContract) createHealthcare(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 5 {
		return shim.Error("Incorrect number of arguments. Expecting 5")
	}
	
	var healthcare = Document{ Hash:args[1], UTF8:args[2], Name: "Healthcare", Date:args[4] } 

	HealthDoqAsBytes, _ := json.Marshal(healthcare)
	APIstub.PutState(args[0]+"Health"+args[3], HealthDoqAsBytes)

	return shim.Success(nil)
}

func (s *SmartContract) createBloodline(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 4 {
		return shim.Error("Incorrect number of arguments. Expecting 4")
	}

	var bloodline = Document{ Hash:args[1], UTF8:args[2], Name: "Bloodline", Date:args[3] } 

	BloodDoqAsBytes, _ := json.Marshal(bloodline)
	APIstub.PutState(args[0]+"Blood", BloodDoqAsBytes)

	return shim.Success(nil)
}
func (s *SmartContract) createDiagnostic(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 5 {
		return shim.Error("Incorrect number of arguments. Expecting 5")
	}

	var diagnostic = Document{ Hash:args[1] , UTF8:args[2] , Name: "Diagnostic", Date:args[4] }

	DiagnosticDoqAsBytes, _ := json.Marshal(diagnostic)
	APIstub.PutState(args[0]+"Diagnostic"+args[3], DiagnosticDoqAsBytes)

	return shim.Success(nil)
}

// The main function is only relevant in unit test mode. Only included here for completeness.
func main() {

	// Create a new Smart Contract
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract: %s", err)
	}
}
